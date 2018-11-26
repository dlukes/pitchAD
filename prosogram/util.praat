# util.praat --- Praat include file containing some utilities 

# Last modification: 2012-03-25


# call util_test

procedure util_test
   a$ = " 1, 2, 3,abc,5 "
   b = 1
   repeat
      call next_field 'a$'
      printline input=<'a$'> next_field=<'result2$'> rest_string=<'result3$'>
      a$ = result3$
      b += 1
   until (result <= 0 or b > 10)
   exit

   a$ = " 1234 6789  "
   call rtrim 'a$'
   printline a="'a$'" result="'result$'"

   a$ = "c:/a/b/c/fname.ext"
   call fname_parts 'a$'
   printline 'result1$'
   printline 'result2$'
   printline 'result3$'
   printline 'result4$'
   printline 'result5$'
   printline 'result6$'
endproc


procedure ltrim s_$
# remove all blanks at start of input string
# and return resulting string in result$
   result$ = s_$
   while (length (result$) > 0 and left$ (result$, 1) = " ")
      result$ = right$ (result$, 2, length(result$) - 1)
   endwhile
endproc


procedure rtrim s_$
# remove all blanks at end of input string
# and return resulting string in result$
   result$ = s_$
   len_ = length (result$) 
   while (len_ > 0 and right$ (result$, 1) = " ")
      result$ = left$ (result$, len_ - 1)
      len_ -= 1 
   endwhile
endproc


procedure btrim s_$
# remove all blanks at start and end of input string
# and return resulting string in result$
   result$ = s_$
   while (length (result$) > 0 and left$ (result$, 1) = " ")
      result$ = right$ (result$, 2, length(result$) - 1)
   endwhile
   len_ = length (result$) 
   while (len_ > 0 and right$ (result$, 1) = " ")
      result$ = right$ (result$, len_ - 1)
      len_ -= 1 
   endwhile
endproc


procedure fname_parts s_$
# Obtain filename parts
# s_$		the total filename
# result1$	the filename without path
# result2$	the basename (i.e. no path, no extension)
# result3$	the filename extension (excluding dot)
# result4$	the file path (including trailing slash) including drive
# result5$	the file path (including trailing slash) excluding drive
# result6$	the drive (excluding separator ':' )
   result1$ = s_$
   result2$ = ""
   result3$ = ""
   result4$ = ""
   result5$ = ""
   result6$ = ""
   pos_ = rindex (s_$, "\")
   if (pos_ = 0)
      pos_ = rindex (s_$, "/")
   endif
   if (pos_ > 0)
      result4$ = mid$ (s_$, 1, pos_)
      len_ = length (s_$) - pos_
      result1$ = mid$ (s_$, pos_ + 1, len_)
   endif
   pos_ = rindex (result1$, ".")
   if (pos_ > 0)
      len_ = length (result1$)
      result3$ = right$ (result1$, len_ - pos_)
      result2$ = left$ (result1$, pos_ - 1)
   else
      result2$ = result1$     
   endif
   pos_ = index (result4$, ":")
   if (pos_ = 2)
      len_ = length (result4$)
      result5$ = right$ (result4$, len_ - pos_)
      result6$ = left$ (result4$, pos_ - 1)
   else
      result5$ = result4$
   endif
endproc


procedure interval_from_time gridID tiernr t varname$
# Return in <result> the interval number within tier <tiernr> of TextGrid <gridID> 
# in which time <t> occurs, taking into account cases where time is outside grid range
   select gridID
   result = Get interval at time... tiernr t
   if (result == 0) ; time outside grid range
      tmp = Get starting time
      if (t <= tmp)
         result = 1
      else
         tmp = Get finishing time
         if (t >= tmp)
            result = Get number of intervals... tiernr
         endif
      endif
   endif
   'varname$' = result
endproc


procedure tier_number_by_name gridID name$
# Return in <result> the number of first tier corresponding to tier name.
# Return 0 if tier with name does not exist in textgrid.
# The target tier name may be a regular expression.
# Return tier name in <result2$>
   select gridID
   n_ = Get number of tiers
   result = 0
   tier_ = 1
   while (tier_ <= n_ and result = 0)
      result2$ = Get tier name... tier_
      if (index_regex (result2$, 'name$')) 
         result = tier_
      else
         tier_ += 1
         result2$ = ""
      endif
   endwhile
endproc


procedure tier_get gridID_ tiername$ varname$ message$ fatal_
# In TextGrid object <gridID_>, find a tier with a name matching the regular expression
# in <tiername$> and return its number as the value of variable named <varname$>.
# When such a tier is not found, print the error message and exit is <fatal_> is true.
   call tier_number_by_name gridID_ tiername$
   if (result < 1)
      if (fatal_)
         call fatal_error 'message$'
      else
         call error_msg 'message$'
      endif
   endif
   'varname$' = result
endproc


procedure grid_show_tiers gridID
   printline Showing tier names
   select gridID
   n_ = Get number of tiers
   tier_ = 1
   while (tier_ <= n_)
      s$ = Get tier name... tier_
      printline Tier 'tier_', name= <'s$'>
      tier_ += 1
   endwhile
endproc


procedure copy_tier srcgrid srctier destgrid desttier
# assumes destination tier is empty
   select srcgrid
   interval_tier = Is interval tier... srctier
   if (interval_tier)
      select destgrid
      n = Get number of intervals... desttier
      endtime_ = Get end point... desttier n 
      select srcgrid
      n = Get number of intervals... srctier
      for i to n
         select srcgrid
         t1_ = Get start point... srctier i
         t2_ = Get end point... srctier i
         label$ = Get label of interval... srctier i
         select destgrid
         if (t2_ < endtime_ and i < n)
            Insert boundary... desttier t2_
         endif
         if (t1_ <= endtime_ )
            t2_ = min (t2_, endtime_)	; when destgrid is shorter than srcgrid
	    j = Get interval at time... desttier (t1_ + (t2_ - t1_)/2)
            Set interval text... desttier j 'label$'
         endif
      endfor
   else
      select srcgrid
      n = Get number of points... srctier
      for i to n
         select srcgrid
         t = Get time of point... srctier i
         label$ = Get label of point... srctier i
         select destgrid
         Insert point... desttier t 'label$'
      endfor
   endif
endproc


procedure tier_clear gridID_ tier_
   select gridID_
   interval_tier = Is interval tier... tier_
   if (interval_tier)
      i = Get number of intervals... tier_
      i -= 1
      while (i > 0)
	 Remove right boundary... tier_ i
         i -= 1
      endwhile
   else
      n_ = Get number of points... tier_
      for i to n_
         Remove point... i
      endfor
   endif
endproc


procedure tier_clear_text grid_ tier_
   select grid_
   interval_tier = Is interval tier... tier_
   if (interval_tier)
      n_ = Get number of intervals... tier_
      empty$ = ""
      for i_ from 1 to n_
         Set interval text... tier_ i_ 'empty$'
      endfor
   endif
endproc


procedure tier_replace srcgrid srctier destgrid desttier
   call tier_clear destgrid desttier
   call copy_tier srcgrid srctier destgrid desttier
endproc


procedure grid_append_tier gridin tierin gridname$
# append tier <tierin> from <gridin> to <gridname$>
# replaces value of <gridout>
   select gridin
   ok = Is interval tier... tierin
   Extract tier... tierin
   if (ok)
      tmp = selected ("IntervalTier",-1)
   else
      tmp = selected ("TextTier",-1)
   endif
   grid_ = 'gridname$'
   select grid_
   plus tmp
   Append
   tmp2 = selected ("TextGrid",-1)
   select tmp
   plus grid_
   Remove
   'gridname$' = tmp2
endproc


procedure next_field s_$
# Get next field form a string with comma-separated fields.
# Return success in <result>, return field in <result2$>, return rest of string in <result3$>
   result2$ = ""
   len_ = length (s_$) 
   while (len_ > 0 and left$ (s_$, 1) = " ")	; ltrim input
      s_$ = right$ (s_$, len_ - 1)
      len_ -= 1 
   endwhile
   if (len_ == 0)
      result = 0
   else
      pos_ = index (s_$, ",")
      if (pos_ = 0)
         result3$ = ""
      else
         result3$ = right$ (s_$, len_ - pos_)		; rest of strings
         s_$ = left$ (s_$, pos_ - 1)
         len_ = length (s_$)
      endif
      while (len_ > 0 and left$ (s_$, 1) = " ")		; ltrim field
         s_$ = right$ (s_$, len_ - 1)
         len_ -= 1 
      endwhile
      while (len_ > 0 and right$ (s_$, 1) = " ")	; rtrim field
         s_$ = left$ (s_$, len_ - 1)
        len_ -= 1 
      endwhile
      if (length (s_$) == 0)
         result = 0
      else
         result = 1
         result2$ = s_$
      endif
   endif
endproc


procedure is_number s_$
    result = extractNumber(s_$, "")
    if (result == undefined)
       result = 0
    else
       result = 1
    endif
endproc


procedure convert_Hz_ST objectID
# Convert a PitchTier from Hz values to ST scale, relative to 1 Hz
   yoffset = hertzToSemitones(1)
   select objectID
   n = Get number of points
   for i from 1 to n
      x = Get time from index... i
      y = Get value at index... i
      Remove point... i
      yST =  hertzToSemitones(y) - yoffset
      Add point... x yST
   endfor
endproc


procedure convert_ST_Hz objectID
# Convert a PitchTier from ST values (relative to 1 Hz) to Hz values 
   yoffset = hertzToSemitones(1)
   select objectID
   n = Get number of points
   for i from 1 to n
      x = Get time from index... i
      y = Get value at index... i
      Remove point... i
      y =  semitonesToHertz(y + yoffset)
      Add point... x y
   endfor
endproc

# ------------------------------ Messages ------------------------------ #



procedure logging_start
   logging = 1
   logfile$ = "log.txt"
   filedelete 'logfile$'
   call msg Logging to 'logfile$' started
endproc


procedure msg message_$
   if (variableExists ("logging"))
      if (logging > 0)
;printline msg logging='logging'
         date_$ = date$ ()
         fileappend 'logfile$' @ 'date_$''newline$'
         fileappend 'logfile$' 'message_$''newline$'
      endif
   endif
   printline 'message_$'
endproc


procedure time_msg message_$
   date_$ = date$ ()
   call msg 'date_$' 'message_$'
endproc


procedure error_msg message$
   call msg *** ERROR *** 'message$'
endproc


procedure fatal_error message$
   call msg *** ERROR *** 'message$'
   exit
endproc


# ------------------------------ Miscellaneous ------------------------------ #


procedure toggle varname$
   if ('varname$' == 0)
      'varname$' = 1
   else
      'varname$' = 0
   endif
endproc


procedure play_part objectID starttime endtime
     select objectID
     tmpsoundID = Extract part... starttime endtime Rectangular 1.0 yes
     ; Rename... play_part
     Play
     Remove
endproc

