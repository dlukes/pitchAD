# segment.praat --- Praat include file 
# Author: Piet Mertens
# Last modification: 2012-03-25


procedure make_segmentation segm_method anal_x1 anal_x2 destID
# Make a segmentation based on a parameter (which can be intensity, loudness, 
# etc, stored in Intensity object), in time range <anal_x1> to <anal_x2>.
# The resulting interval tier is written in textgrid <destID>, created before calling this procedure. 
   select destID
   tfin = Get end time
   tbeg = Get start time
   mindiff = 3		; intensity difference threshold for local dips in convex hull
   if (segm_method == segm_vnucl)
      call local_peaks_vowels destID intensityID anal_x1 anal_x2
   elsif (segm_method == segm_aloudness)
      call convexhull destID dip_tier loudnessID anal_x1 anal_x2 mindiff
      call tier_point_to_interval destID dip_tier syllable_tier anal_x1 anal_x2
      call local_peaks_loudness destID loudnessID anal_x1 anal_x2
   elsif (segm_method == segm_anucl)
      call convexhull destID dip_tier intbpID anal_x1 anal_x2 mindiff
      call tier_point_to_interval destID dip_tier syllable_tier anal_x1 anal_x2
      call local_peaks_duo destID intensityID intbpID anal_x1 anal_x2
   elsif (segm_method == segm_asyll)
      call pseudo_syllables destID intensityID intbpID anal_x1 anal_x2
   elsif (segm_method == segm_msyllvow)
      call local_peaks_syllables_vowels destID intensityID anal_x1 anal_x2
   elsif (segm_method == segm_msyllpeak)
      call local_peaks_syllables destID intensityID anal_x1 anal_x2
   elsif (segm_method == segm_mrime)
      call local_peaks_rime destID intensityID anal_x1 anal_x2
   elsif (segm_method == segm_voiced)
      call voiced_portions destID intensityID anal_x1 anal_x2
   endif
endproc


procedure local_peaks_vowels grid paramID t1 t2
# grid = ID of destination textgrid where nuclei will be stored
# paramID = parameter for which local peak is to be found
# t1 = start of interval
# t2 = end of interval
    call interval_from_time grid phone_tier t1 first_interval
    call interval_from_time grid phone_tier t2 last_interval

    for j_ from first_interval to last_interval
	x1_ = Get start point... phone_tier j_
	x2_ = Get end point... phone_tier j_
	label$ = Get label of interval... phone_tier j_
	call is_vowel 'label$'
	if (is_vowel)
	    call get_local_peak grid paramID x1_ x2_ tfin 1 x1_ x2_
	endif
    endfor
endproc


procedure local_peaks_syllables grid paramID t1 t2
# grid = ID of destination textgrid where nuclei will be stored
# paramID = parameter for which local peak is to be found
# t1 = start of interval
# t2 = end of interval
    call interval_from_time grid syllable_tier t1 first_interval
    call interval_from_time grid syllable_tier t2 last_interval

    for j_ from first_interval to last_interval
	x1_ = Get start point... syllable_tier j_
	x2_ = Get end point... syllable_tier j_
	label$ = Get label of interval... syllable_tier j_
	label$ = replace_regex$ (label$, "^ *", "", 1)
	label$ = replace_regex$ (label$, " *$", "", 1)
	if (label$ <> "PAUSE" and label$ <> "_")
	    call get_local_peak grid paramID x1_ x2_ tfin 1 x1_ x2_
	endif
    endfor
endproc


procedure local_peaks_syllables_vowels grid paramID t1 t2
# grid = ID of destination textgrid where nuclei will be stored
# paramID = parameter for which local peak is to be found
# t1 = start of interval
# t2 = end of interval
    call interval_from_time grid syllable_tier t1 first_interval
    call interval_from_time grid syllable_tier t2 last_interval
    for j_ from first_interval to last_interval
        x1_ = Get start point... syllable_tier j_
        x2_ = Get end point... syllable_tier j_
;printline syll='j_' ('x1_:3'-'x2_:3')
        call interval_from_time grid phone_tier x1_ ph1
        call interval_from_time grid phone_tier x2_-0.001 ph2
        nrof_vowels = 0
        nrof_syllabics = 0
        for phon from ph1 to ph2
           label$ = Get label of interval... phone_tier phon
                 time_phon = Get start point... phone_tier phon
;printline syll='j_' phon='phon' label='label$' time='time_phon:3' 
           call is_syllabic 'label$'
           if (result)
              nrof_syllabics += 1
              if (is_vowel)
                 nrof_vowels += 1
              endif
	      vowel_x1 = Get start point... phone_tier phon
              vowel_x2 = Get end point... phone_tier phon
              if (nrof_syllabics == 1)
                 call get_local_peak grid paramID x1_ x2_ tfin 1 vowel_x1 vowel_x2
              else
                 call msg Warning: Multiple vowels (or syllabics) in syllable at time 'vowel_x1:3'
              endif
	   endif
	endfor
    endfor
endproc


procedure local_peaks_rime grid paramID t1 t2
# grid = ID of destination textgrid where nuclei will be stored
# paramID = parameter for which local peak is to be found
# t1 = start of interval
# t2 = end of interval
    call interval_from_time grid syllable_tier t1 first_interval
    call interval_from_time grid syllable_tier t2 last_interval
    for j_ from first_interval to last_interval
        syll_x1 = Get start point... syllable_tier j_
        syll_x2 = Get end point... syllable_tier j_
        syll_label$ = Get label of interval... syllable_tier j_
;printline local_peaks_rime: syll='j_' ('syll_x1:4'-'syll_x2:4')
        call interval_from_time grid phone_tier syll_x1 ph1
        call interval_from_time grid phone_tier syll_x2-0.001 ph2
        nrof_vowels = 0
        nrof_syllabics = 0
        for phon from ph1 to ph2
           phon_x1 = Get start point... phone_tier phon
           phon_x2 = Get end point... phone_tier phon
           label$ = Get label of interval... phone_tier phon
           if (phon == ph1 and phon_x1 <> syll_x1)
              call msg Syllable ('syll_label$') starting at 'syll_x1:4' not aligned with phoneme ('label$') start ('phon_x1:4')
	   endif
           if (phon == ph2 and phon_x2 <> syll_x2)
              call msg Syllable ('syll_label$') ending at 'syll_x2:4' not aligned with phoneme ('label$') end ('phon_x2:4')
	   endif
		 time_phon = Get start point... phone_tier phon
           call is_syllabic 'label$'
;printline local_peaks_rime: syll='j_' sound('phon')='label$' is_vowel='result'
           if (result)
              nrof_syllabics += 1
              if (is_vowel)
                 nrof_vowels += 1
              endif
              vowel_x1 = Get start point... phone_tier phon
              vowel_x2 = Get end point... phone_tier phon
              if (nrof_syllabics == 1)
                 call get_local_peak grid paramID vowel_x1 syll_x2 tfin 1 vowel_x1 vowel_x2
;printline local_peaks_rime: syll='j_' left='left:4' right='right:4'
              else
                 call msg Warning: Multiple vowels (or syllabics) in syllable at time 'vowel_x1:3'
              endif
           endif
	endfor
    endfor
endproc


procedure local_peaks_loudness grid paramID t1 t2
# grid = ID of destination textgrid where nuclei will be stored
# paramID = parameter for which local peak is to be found
# t1 = start of interval
# t2 = end of interval
   ; call tier_point_to_interval grid dip_tier syllable_tier t1 t2
   time = t1
   while (time < t2)
      select grid
      j_ = Get interval at time... syllable_tier time
      x1_ = Get start point... syllable_tier j_
      x2_ = Get end point... syllable_tier j_
      call get_local_peak grid paramID x1_ x2_ tfin 1 x1_ x2_
      time = x2 ; x2 returned by get_local_peak
   endwhile
endproc


procedure local_peaks_duo dstID paramID ifilID t1 t2
# dstID = ID of destination textgrid where nuclei will be stored
# paramID = parameter (intensity of unfiltered signal)
# ifilID = intensity of bandpass filtered signal
# t1 = start of interval
# t2 = end of interval
#
# Find syllabic nucleus within syllable-like interval
# - For a voiced portion... 
# - Evaluate importance of difference between maximum of global intensity 
#   and dip at right end of segment. This affects right side of nucleus.
# - From intensity peak (of filtered), go left/right until max difference
#   reached.

   mindur_nucl = 0.025	; minimum duration of nucleus (otherwise rejected)
   diff_left = 2

   ; call tier_point_to_interval dstID dip_tier syllable_tier t1 t2
   time = t1
   while (time < t2)
      select dstID
      j_ = Get interval at time... syllable_tier time
      x1 = Get start point... syllable_tier j_
      x2 = Get end point... syllable_tier j_
;printline local_peaks_duo: time='time:3'
      call is_unvoiced_region x1 x2
      # default values used in case of error
         left = x1
         right = x2
      if (result = 1)	; fully unvoiced
         call set_boundary_label dstID syllable_tier x1 x2 U
      else		; fully or partly voiced
         call get_peak_duo x1 x2
;printline after get_peak_duo: left='left:3' right='right:3' valid='valid'
         call add_boundary dstID nucleus_tier left tbeg tfin
         call add_boundary dstID nucleus_tier right tbeg tfin
         if (valid)	; variable set by get_peak_duo 
            call add_boundary dstID syllable_tier left tbeg tfin
            call add_boundary dstID syllable_tier right tbeg tfin
            if (left-x1 > time_step)
               call set_boundary_label dstID syllable_tier x1 left <
            endif
            if (x2-right > time_step)
               call set_boundary_label dstID syllable_tier right x2 >
            endif
            call set_boundary_label dstID nucleus_tier left right a
            call set_boundary_label dstID syllable_tier left right a
         else ; invalid nucleus (too short)
            call set_boundary_label dstID nucleus_tier left right reject
            call set_boundary_label dstID syllable_tier x1 x2 <>
         endif ; valid
      endif ; voiced
      time = x2
   endwhile
endproc


procedure get_peak_duo x1p x2p
; returns values in <valid>, <left>, <right>
   valid = 0
   select intbpID
   tmaxfil = Get time of maximum... x1p x2p Parabolic
   select intensityID		; intensity full bandwidth
   tmax = Get time of maximum... x1p x2p Parabolic
   max = Get maximum... x1p x2p Parabolic
   if (max == undefined)	; can happen at end of signal, where intensity is undefined
      call msg get_peak_duo: max undefined at time x1='x1p:3', x2='x2p:3'
   else
      repeat			; can happen at end of signal, where intensity is undefined
         select intensityID
         dip_int = Get value at time... x2p Nearest
         select intbpID
         dip_intbp = Get value at time... x2p Nearest
         if (dip_int == undefined or dip_intbp == undefined)
            call msg get_peak_duo: dip undefined at time 'x2p:3'
            x2p -= time_step 
         endif
      until (dip_int <> undefined and dip_intbp <> undefined)
	 call get_boundary intbpID tmaxfil x1p -1 diff_left
         left_filt = result
	 call get_boundary intensityID tmax x1p -1 diff_left
         left = max (left_filt, result)		; select rightmost of both candidates
;	 diff_right = min(9, max (3, (max-dip_intbp)/2 )) 
	 diff_right =        max (3, (max-dip_intbp)/2 ) 
         call get_boundary intbpID tmaxfil x2p 1 diff_right
         right_filt = result
;	 diff_right = min(9, max (3, (max-dip_int)/2 )) 
	 diff_right =        max (3, (max-dip_int)/2 ) 
         call get_boundary intensityID tmax x2p 1 diff_right
         right = max (right_filt, result)	; select rightmost of both candidates
         right = min (x2p, right)		; different time unit in get_boundary
	 call voiced_intersection left right
         if (result > 0 and right-left >= mindur_nucl)
            valid = 1
         endif
   endif
endproc


procedure find_silences paramID_ dstID dst_tier
; Use Praat's procedure to identify silent pauses on the basis of <paramID_> (usu. intensity) 
; and copy results to tier <dst_tier> of <dstID>
   select dstID
   tfin = Get end time
   tbeg = Get start time
   min_silent_interval = 0.15		; Praat standard = 0.1
   min_sounding_interval = 0.05		; Praat standard = 0.1
;   pause_mindur = min_silent_interval
   select paramID_
   silencesID = To TextGrid (silences)... -25.0 min_silent_interval min_sounding_interval _ a
   Rename... silences
   n_ = Get number of intervals... 1
   ; copy boundaries from silences TextGrid to dstID in time range
   for j to n_
      select silencesID
      label_$ = Get label of interval... 1 j
      x1_ = Get start point... 1 j
      x2_ = Get end point... 1 j
      call add_boundary dstID dst_tier x1_ tbeg tfin
      call add_boundary dstID dst_tier x2_ tbeg tfin
      call set_boundary_label dstID dst_tier x1_ x2_ 'label_$'
   endfor
   select silencesID
   Remove
endproc


procedure voiced_portions dstID intID anal_t1 anal_t2
   call find_silences intID dstID syllable_tier
   # number of intervals grows during loop
   time_ = anal_t1
   call add_boundary dstID nucleus_tier time_ tbeg tfin
   while (time_ + time_step < anal_t2)		; avoid rounding error
      select dstID
      j_ = Get interval at time... syllable_tier time_ 
      label_$ = Get label of interval... syllable_tier j_
      x1_ = Get start point... syllable_tier j_
      x2_ = Get end point... syllable_tier j_
;call msg vp:while t='time_:4' j='j_' x1='x1_:4' x2='x2_:4' label='label_$'
      nexttime = x2_
      call add_boundary dstID nucleus_tier x2_ tbeg tfin
      if (label_$ == "_")	; pause
         call set_boundary_label dstID nucleus_tier x1_ x2_ 'label_$'
      else			; speech
         repeat
;call msg vp:repeat x1='x1_:4' x2='x2_:4'
            call voiced_intersection x1_ x2_
;call msg vp:voiced_intersection result='result' left='left:4' right='right:4'
            if (result)		; it contains a voiced part
               if (left-x1_ > time_step)
                  call add_boundary dstID nucleus_tier left tbeg tfin
                  call set_boundary_label dstID nucleus_tier x1_ left U
               endif
               call add_boundary dstID nucleus_tier right tbeg tfin
               call set_boundary_label dstID nucleus_tier left right a
               x1_ = right
            else
               x1_ = x2_
            endif
;call msg vp:until x1='x1_:4' x2='x2_:4'
         until (x1_ >= x2_)
      endif
      time_ = nexttime
   endwhile
endproc


procedure pseudo_syllables dstID intID ifilID at1 at2
   call find_silences intID dstID syllable_tier
   call mark_unvoiced dstID dip_tier at1 at2
   # number of intervals grows during loop
   time_ = at1
   while (time_ + time_step < at2)		; avoid rounding error
      select dstID
      j_ = Get interval at time... syllable_tier time_
      label_$ = Get label of interval... syllable_tier j_
      x1_ = Get start point... syllable_tier j_
      x2_ = Get end point... syllable_tier j_
      nexttime = x2_
      if (label_$ = "a")
         call convexhull dstID dip_tier ifilID x1_ x2_ mindiff
	 if (result)
            call tier_point_to_interval dstID dip_tier syllable_tier x1_ x2_
            call local_peaks_duo dstID intID ifilID x1_ x2_
         endif
      endif
      time_ = nexttime
   endwhile

   call pass4 intID dstID syllable_tier
endproc


procedure mark_unvoiced dstID tier_ at1 at2
# add boundaries to tier_ (point tier) in dstID, at voiced-unvoiced transitions
   select dstID
   n_ = Get number of intervals... vuv_tier
   prev$ = ""
   time_ = at1
   while (time_ < at2)
      j_ = Get interval at time... vuv_tier time_ 
      label_$ = Get label of interval... vuv_tier j_
      x2_ = Get end point... vuv_tier j_
      if (label_$ = "U" and prev$ = "V")
         x1_ = Get start point... vuv_tier j_
         call tier_point_add dstID tier_ x1_ 0
      endif
      prev$ = label_$
      time_ = x2_
      if (j_ == n_)
         time_ = at2	; exit loop
      endif
   endwhile
endproc


procedure pass4 intID dstID tier_
; 1. Group sequences   [<] a [>]
   select dstID
   n_ = Get number of intervals... tier_
   j = 2
   while (j <= n_)
      select dstID
      label_$ = Get label of interval... tier_ j
      if (label_$ = "a")
         x1_ = Get start point... tier_ j
         x2_ = Get end point... tier_ j
         select intID
	 ymax_ = Get maximum... x1_ x2_ Parabolic
         select dstID
         Set interval text... tier_ j syl
         if (j > 1) 
            prevlabel_$ = Get label of interval... tier_ j-1
            if (prevlabel_$ = "<")
               Remove left boundary... tier_ j
               j -= 1
               n_ -= 1
               Set interval text... tier_ j syl
	    endif
         endif
         if (j < n_) 
            nextlabel_$ = Get label of interval... tier_ j+1
            x_ = Get end point... tier_ j
            select intID
            y_ = Get value at time... x_ Nearest
            if (nextlabel_$ = ">" and ymax_ - y_ < 25)
               select dstID
               Remove right boundary... tier_ j
               n_ -= 1
               Set interval text... tier_ j syl
	    endif
         endif
      endif ; label_$ = "a"
      j += 1
   endwhile
; 2. Group unvoiced rejected nuclei with next syllable
if (0)
   j = 1
   while (j <= n_)
      select dstID
      label_$ = Get label of interval... tier_ j
      if (label_$ = "reject")		; nucleus too short 
         x1_ = Get start point... tier_ j
         x2_ = Get end point... tier_ j
         call unvoiced_proportion x1_ x2_
         unvoiced = result
         select dstID
         if (unvoiced < 0.7)
            Set interval text... tier_ j UVP='unvoiced:1'
         else
            if (j < n_) 
               nextlabel_$ = Get label of interval... tier_ j+1
               if (nextlabel_$ = "syl")
                  Remove right boundary... tier_ j
                  n_ -= 1
                  Set interval text... tier_ j syl
	       else
                  Set interval text... tier_ j UVP>=.7
	       endif
            endif
         endif ; unvoiced 
      endif ; label "reject"
      j += 1
   endwhile
endif
   if (1)
      j = 1
      while (j <= n_)
         select dstID
         label_$ = Get label of interval... tier_ j
         if (label_$ = "syl")
               if (j > 1) 
                  prevlabel_$ = Get label of interval... tier_ j-1
                  ; if (prevlabel_$ = "<>" or prevlabel_$ = "U")
                  if (prevlabel_$ = "U")
                     Remove left boundary... tier_ j
                     n_ -= 1
                     j -= 1
                     Set interval text... tier_ j syl
                  endif
               endif
         endif
         j += 1
      endwhile
   endif 
endproc


procedure get_local_peak dstID paramID x1 x2 tfin dyn_threshold seed_x1 seed_x2
# Find max in interval <seed_x1>..<seed_x2>. Find boundaries inside <x1>..<x2>.
   mindur_nucl = 0.025	; minimum duration of nucleus (otherwise rejected)
   select paramID
   time_step = Get time step
   ; default values used in case of error
      left = x1		; left boundary of peak
      right = x2	; right boundary of peak
      label2$ = "-"	; not a nucleus
      valid = 0		; not a valid nucleus
   call is_unvoiced_region x1 x2
;printline get_local_peak: x1='x1:3' dyn_threshold='dyn_threshold' is_unvoiced_region='result' 
   if (result = 0)		; not fully unvoiced, i.e. partly voiced
      select paramID
      maxtime = Get time of maximum... seed_x1 seed_x2 Parabolic
      max = Get maximum... seed_x1 seed_x2 Parabolic
;printline get_local_peak: x1='x1:3' maxtime='maxtime:5' max='max:5'
      if (max = undefined)	; can happen at both ends of signal, where intensity is undefined
         call msg get_local_peak: max undefined at 'maxtime:3', seed_x1='seed_x1:3' seed_x2='seed_x2:3'
         # use defaults
      else			; max is defined
         # find left boundary
         dipL = Get value at time... x1 Nearest
         if (dipL = undefined)
            call msg get_local_peak: dip left undefined at time 'x1:3'
         else
            diff_left = 3
            ;if (dyn_threshold)
            ;   diff_left = max(2, (max - dipL)/2)
            ;endif
            call get_boundary paramID maxtime x1 -1 diff_left
            left = result
            if ((segm_method == segm_vnucl or segm_method == segm_mrime) and left-seed_x1 >= 0.075)
               left = seed_x1 + 0.02
;printline get_local_peak: x1='x1:3' changing left side to 'left:5'
   	 endif
;printline get_local_peak: x1='x1:3' left='left:5'
         endif
         # find right boundary
         ; dip = Get value at time... x2 Nearest
         dip = Get minimum... maxtime x2 Parabolic
         if (dip = undefined)
            call msg get_local_peak: dip right undefined at time 'x2:3'
         else
            diff_right = 9
            if (dyn_threshold)
               diff_right = max(3, (max - dip)*0.80) 
            endif
            call get_boundary paramID maxtime x2 1 diff_right
            right = result
;printline get_local_peak: x1='x1:3' right='right:5'
         endif
         if (dipL != undefined and dip != undefined)
            call voiced_intersection left right
;printline get_local_peak: voiced_intersection left='left:5' right='right:5' result='result'
            if (result > 0 and right-left >= mindur_nucl)
               label2$ = "a"
               valid = 1
            endif
         endif
      endif
   endif ; voiced
;printline adding boundaries x1='x1:5' left='left:5' right='right:5' x2='x2:5' label='label2$' valid='valid'
   call add_boundary dstID nucleus_tier left tbeg tfin
   call add_boundary dstID nucleus_tier right tbeg tfin
   call set_boundary_label dstID nucleus_tier left right 'label2$'
   if (valid)
      call add_boundary dstID nucleus_tier x1 tbeg tfin
      call add_boundary dstID nucleus_tier x2 tbeg tfin
      if (left-x1 > time_step)
         call set_boundary_label dstID nucleus_tier x1 left <
      endif
      if (x2-right > time_step)
         call set_boundary_label dstID nucleus_tier right x2 >
      endif
   endif ; valid
endproc


procedure convexhull gridID tier_ paramID x1 x2 mindiff
# gridID = textgrid in which segmentation points are stored
# tier_ = point tier where points are stored
# paramID = parameter on which segmentation is based
# x1 = start time of analysis
# x2 = end time of analysis
   convexhull_winlen = 0.75
   select gridID
   tfin = Get end time
   tbeg = Get start time
   select paramID
   dx = Get time step

   # Skip part at start of signal for which parameter is undefined
   x = x1
   xL = x1
   repeat
      y1 = Get value at time... x Nearest
      if (y1 == undefined)
	 x += dx
      else
         xL = x
      endif
   until ((not y1 == undefined) or x > x2)
   # Skip part at end of signal for which parameter is undefined
   x = x2
   xR = x2
   repeat
      y2 = Get value at time... x Nearest
      if (y2 == undefined)
         x -= dx
      else
         xR = x
      endif
   until ((not y2 == undefined) or x < x1)

   if (y1 == undefined or y2 == undefined)
      result = 0
   else
      while (xL < xR)
         xlast = min (xL + convexhull_winlen, xR)
         dip_ = 0
         repeat
            call time_maxdiff paramID xL xlast dx mindiff
            if (tmaxdif >= 0)
               xlast = tmaxdif
               dip_ = maxdif
	    endif
         until (tmaxdif < 0)
         if (dip_ > mindif)
            call tier_point_add gridID tier_ xlast 'dip_:1'
         endif
         xL = xlast ; shift start of analysis window to end of previous
      endwhile
      result = 1
   endif
endproc


procedure time_maxdiff paramID xh1 xh2 dx mindif
# returns <tmaxdif>, <maxdif>, <result>
# <result> found a dip, such that (dif >= mindiff)
      select paramID
      maxdif = 0.0
      tmax_ = Get time of maximum... xh1 xh2 Parabolic
      if (tmax_ > xh1)
         x = xh1
         tmaxdif = xh1
         h = Get value at time... x Nearest
	 while (x < tmax_)	; locate max diff while going up hull to peak
            y = Get value at time... x Nearest
            if (h-y > maxdif)
               maxdif = h-y
               tmaxdif = x
            endif
            h = max (y,h)
            x += dx
         endwhile
      endif
      if (tmax_ < xh2)
         x = xh2
         h = Get value at time... x Nearest
         while (x > tmax_)
            y = Get value at time... x Nearest
            if (h-y > maxdif)
               maxdif = h-y
               tmaxdif = x
            endif
            h = max (y,h)
            x -= dx
         endwhile
      endif
      if (maxdif >= mindif)
         result = 1
      else
	 result = 0
	 tmaxdif = -1
      endif
endproc


procedure add_boundary destID_ tier_ xbound xstart xstop
# Add a boundary, avoiding 
# - adding left boundary where right boundary of previous segment is
# - adding boundary where starttime of object is
# - adding boundary where endtime of object is
# xbound = time of boundary
# xstop = endtime of tier
   select destID_
   i_ = Get interval at time... tier_ xbound
   if (i_ <= 0)
      call msg add_bound i<=0 xbound='xbound'     
   endif
   t1_ = Get start point... tier_ i_
   t2_ = Get end point... tier_ i_
   if (abs(t1_-xbound) > time_step and abs(t2_-xbound) > time_step and xbound > xstart and xbound < xstop)
      Insert boundary... tier_ xbound
   endif
endproc


procedure tier_point_add destID_ tier_ x_ text_$
   select destID_
   i_ = Get nearest index from time... tier_ x_
   if (i_ == 0) ; no points in tier
      Insert point... tier_ x_ 'text_$'
   else
      t_ = Get time of point... tier_ i_
      if (t_ == x_)
         call msg already a point at time 'x_:3' 
      else
         Insert point... tier_ x_ 'text_$'
      endif
   endif
endproc


procedure set_boundary_label destID_ tier_ xleft xright label_$
   select destID_
   midtime = xleft+(xright-xleft)/2
   interval = Get interval at time... tier_ midtime
   Set interval text... tier_ interval 'label_$'
endproc


procedure get_boundary paramID peaktime xlimit incr diff
   result = 0
   select paramID
   peakframe = Get frame from time... peaktime
   i = round (peakframe)
   max = Get value in frame... peakframe
   limit_ = Get frame from time... xlimit
   limit = round (limit_)
;printline get_boundary: peaktime='peaktime:5' xlimit='xlimit:5' limit_='limit_' round limit='limit'
   ok = 1
   while (ok)
      nexti = i + incr
      iy = Get value in frame... i
      if ((incr < 0 and nexti < limit) or (incr > 0 and nexti > limit) or (max-iy > diff))
	 ok = 0
      else
         i = nexti
         if (incr < 0 and i <= 0)
            ok = 0
            i = 1
	 endif
      endif
   endwhile
   result = Get time from frame... i
   if (incr > 0)	; frame is real number -> rounding errors
      result = min (result, xlimit)
   else
      result = max (result, xlimit)
   endif
;printline get_boundary: end. time result='result:5'
endproc


procedure tier_point_to_interval gridID ptier_ itier_ t1_ t2_
# Convert points in points tier <ptier_> to intervals in <itier_>
   select gridID
   tfin_ = Get end time
   tbeg_ = Get start time
   n_ = Get number of points... ptier_
   for j_ to n_
      time = Get time of point... ptier_ j_
      if (time >= t1_ and time <= t2_)
         call add_boundary gridID itier_ time tbeg_ tfin_
      endif
   endfor
endproc


procedure is_unvoiced_region x1 x2
# returns 1 if <x1> and <x2> are within same unvoiced interval of the VUV grid
   result = 0
   select nucleiID
   i1 = Get interval at time... vuv_tier x1
   if (i1 = 0)		; peeking before analysed signal; return unvoiced
      printline is_unvoiced_region: i1='i1' x1='x1'
      result = 1
   else
      i2 = Get interval at time... vuv_tier x2
      label$ = Get label of interval... vuv_tier i1
;printline is_unvoiced_region: i1='i1' x1='x1:3' i2='i2'
      if (i1 == i2 and label$ = "U")
         result = 1
      endif
   endif
endproc


procedure unvoiced_proportion x1_ x2_
# returns proportion of unvoiced part inside <x1_>..<x2_> 
# returns left, right: the unvoiced part inside <x1_>..<x2_>
   result = 0
   select nucleiID
   ni_ = Get number of intervals... vuv_tier
   i_ = Get interval at time... vuv_tier x1_
   if (i_ == 0)
      # peeking outside analysed signal; return unvoiced
      call msg error in unvoiced_proportion i='i_' x1='x1_'
      result = 0
   else
      ux1 = x2_
      ux2 = ux1
      repeat
         label_$ = Get label of interval... vuv_tier i_
         t1_ = Get start point... vuv_tier i_
         t2_ = Get end point... vuv_tier i_
	 if (label_$ = "U")
            ux1 = max(x1_, t1_)
         endif        
         i_ += 1
      until (ux1 < x2_ or t1_ >= x2_ or i_ >= ni_)
      ux2 = min (t2_, x2_)
      result = (ux2 - ux1) / (x2_ - x1_)
   endif
endproc


procedure voiced_intersection x1_ x2_
# returns 1 in <result> if there is a voiced part inside <x1_>..<x2_> 
# returns <left>, <right>: the voiced part inside <x1_>..<x2_>
   result = 0
   select nucleiID
   i1 = Get interval at time... vuv_tier x1_
   i2 = Get interval at time... vuv_tier x2_
   if (i1 == 0 or i2 == 0)	; peeking outside analysed signal; return unvoiced
      call error_msg voiced_intersection: i1='i1' x1='x1_'
   else
      while (i1 <= i2)
         label_$ = Get label of interval... vuv_tier i1
         if (label_$ = "V")
            if (result == 0)
               sp1 = Get start point... vuv_tier i1
               left = max (sp1, x1_)
            endif
            ep1 = Get end point... vuv_tier i1
            right = min (x2_, ep1)
            result = 1
         else
            if (result == 1)
               i1 = i2+1
            endif
         endif
         i1 += 1
      endwhile
   endif
endproc


procedure is_vowel s$
# Sets variable is_vowel to 1 if s$ is a vowel (SAMPA or Praat conventions) 
# and to 0 otherwise
   is_vowel = 0
   s$ = replace$ (s$, "`", "", 0)		; remove all rhoticity diacritics
   s$ = replace_regex$ (s$, "^i_d$", "i", 1)	; dental i in X-SAMPA
   s$ = replace_regex$ (s$, ":$", "", 1)	; diacritic indicating lengthening
   len = length (s$)
   first$ = left$ (s$, 1)
   if (index_regex (s$, "^[aeiouyAEIOUYOQV@23679&\{\}]+$") )	; 1 or more vocalic elements
      is_vowel = 1
   elsif (len = 1 and s$ = "V")				; special convention (on request)
      is_vowel = 1
   elsif (len = 2)
      if (index ("~a~e~o~E~O~A~9~U~", s$))		; nasal vowels; U~ used by some
         is_vowel = 1
      elsif (index (":\o:", ":'s$':"))
         is_vowel = 1
      endif
   elsif (len = 3 and first$ = "\" )
      z$ = mid$ (s$,1,3)    ; first three characters
      z2$ = mid$ (s$,1,2)   ; first two characters
      third$ = mid$ (s$, 3, 1)
      if (third$ = """" and (index (":\a:\e:\i:\o:\u:\y:", ":'z2$':")))
         is_vowel = 1 
      elsif (third$ = "-" and (index (":\e:\i:\o:\u:", ":'z2$':")))
         is_vowel = 1 
      elsif (index (":\a~:\o~:", ":'s$':"))    ; nasal vowels
         is_vowel = 1       
      elsif (index (":\o/:\ab:\as:\ae:\at:\ep:\ef:\er:\oe:\Oe:\ct:\vt:\ic:\yc:\sw:\sr:\rh:\hs:\kb:\mt:\u-:", ":'z$':"))
         is_vowel = 1 
      endif
   elsif (len > 3 and index (":a\~^:\ep~:\as\~^:\ep\~^:\ct\~^:", ":'s$':"))
      is_vowel = 1
   endif
endproc


procedure is_syllabic s$
; sets <result> = true is string is vowel or syllabic consonant
; sets <is_vowel> = true if string is a vowel
   call is_vowel 's$'
   if (is_vowel)
      result = 1
   ; elsif (index_regex (s$, "^[mnJNlrR]\\\|v$"))	; Praat phonetic symbol "\|v"
   elsif (index_regex (s$, "^[mnJNlrR]=$"))		; X-SAMPA symbol "="
      result = 1
   else
      result = 0
   endif
endproc
