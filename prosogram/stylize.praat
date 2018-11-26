# stylize.praat -- Praat include file
# Pitch contour stylization. 
# This file is included (indirectly) by prosogram.praat. It isn't a stand-alone script.
# Author: Piet Mertens
# Last modification: 2012-03-25


procedure create_table_of_nuclei
   n_ = nrof_nuclei_analysed
   if (n_ == 0)
      call error_msg No nuclei were found. 
      n_ = 1		; avoid crash
   endif
   nrcols = 31
   nucldatID = Create TableOfReal... nucl_data n_ nrcols
   nucldat_available = 1
   nucleusstarttime = 1 ; starttime of nucleus
   nucleusendtime = 2	; endtime of nucleus
   nucleusdur = 3	; nucleus_duration
   f0_min = 4		; f0 min (Hz) within nucleus            before stylization
   f0_max = 5		; f0 max (Hz) within nucleus            before stylization
   f0_median = 6	; f0 median (Hz) within nucleus 	before stylization
   f0_mean = 7		; f0 mean (ST) within nucleus		before stylization
   f0_start = 8		; f0 value (Hz) at start of nucleus	after stylization
   f0_end = 9		; f0 value (Hz) at end of nucleus	after stylization
   lopitch = 10		; f0 min (Hz) within nucleus		after stylization
   hipitch = 11		; f0 max (Hz) within nucleus		after stylization
   dynamic = 12		; 0 = static, 1 = rising, -1 = falling
   intrasyllab = 13	; sum of pitch interval (ST) of tonal segments in nucleus (rises and falls compensate)
   intrasyllabup = 14	; sum of upward pitch interval (ST) of tonal segments in nucleus
   intrasyllabdown = 15	; sum of downward pitch interval (ST) of tonal segments in nucleus
   intersyllab = 16	; intersyllabic interval (ST) between end of previous nucleus and start of current one
   trajectory = 17	; sum of absolute pitch interval (ST) of tonal segments in nucleus (rises and falls add up)
   internucleusdur = 18	; time between end of previous nucleus and start of current one
   j_int_peak = 19	; peak intensity in nucleus
   j_voweldur = 20	; vowel duration
   j_syllabledur = 21	; syllable duration (only for appropriate segmentation method)
   j_rimedur = 22	; rime duration (only for appropriate segmentation method)
   loudness = 23	; loudness peak in nucleus (only if parameter available)
;  promL2_nucldur = 		; prominence of nucleus duration wrt left context of 2 units
;  promL2R2_nucldur = 		; prominence of nucleus duration wrt left/right context of 2 units
   promL2R1D_nucldur = 24	; prominence of nucleus duration wrt dynamic left/right context of 2+1 units
;  promL2_sylldur = 		; prominence of syllable duration wrt left context of 2 units
;  promL3_sylldur = 		; prominence of syllable duration wrt left context of 3 units
;  promL2R2_sylldur =		; prominence of syllable duration wrt left/right context of 2 units
;  promL2R1_sylldur =		; prominence of syllable duration wrt left/right context of 2+1 units
   promL2R1D_sylldur = 25	; prominence of syllable duration wrt dynamic left/right context of 2+1 units
;  promL3R1_sylldur =		; prominence of syllable duration wrt left/right context of 3+1 units
;  promL2R2_loudness =		; prominence of loudness wrt left/right context of 2 units
   promL2R1D_rimedur = 26	; prominence of rime duration wrt dynamic left/right context of 2+1 units
   promL2R1D_f0_mean = 27	; prominence of mean pitch (Hz) wrt dynamic left/right context of 2+1 units
   j_hesitation = 28		; hesitation found (only when in boundary annotation) 
   speaker_id = 29		; speaker ID number, from tier "speaker" in annotation file
   j_before_pause = 30		; syllable is followed by pause
   endtime_syll = 31		; used by plot_salience (only for appropriate segmentation method)
   Set column label (index)... nucleusstarttime nucl_t1
   Set column label (index)... nucleusendtime nucl_t2
   Set column label (index)... dynamic dynamic
   Set column label (index)... f0_start f0_start
   Set column label (index)... f0_end f0_end
   Set column label (index)... lopitch lopitch
   Set column label (index)... hipitch hipitch
   Set column label (index)... f0_min f0_min
   Set column label (index)... f0_max f0_max
   Set column label (index)... f0_median f0_median
   Set column label (index)... f0_mean f0_mean
   Set column label (index)... intrasyllab intrasyllab
   Set column label (index)... intrasyllabup up
   Set column label (index)... intrasyllabdown down
   Set column label (index)... intersyllab intersyllab
   Set column label (index)... nucleusdur nucl_dur
   Set column label (index)... trajectory trajectory
   Set column label (index)... internucleusdur gap_left
   Set column label (index)... j_voweldur vowel_dur
   Set column label (index)... j_syllabledur syll_dur
   Set column label (index)... j_rimedur rime_dur
   Set column label (index)... endtime_syll endtime_syll
   Set column label (index)... loudness loudness
   Set column label (index)... j_int_peak int_peak
   Set column label (index)... promL2R1D_sylldur promL2R1D_sylldur
   Set column label (index)... promL2R1D_nucldur promL2R1D_nucldur
   Set column label (index)... promL2R1D_rimedur promL2R1D_rimedur
   Set column label (index)... promL2R1D_f0_mean promL2R1D_f0_mean
   Set column label (index)... j_hesitation hesitation
   Set column label (index)... speaker_id speaker_id
   Set column label (index)... j_before_pause before_pause
;  Set column label (index)... internucleustrajectory internucleustrajectory
;  Set column label (index)... promL2_nucldur promL2_nucldur
;  Set column label (index)... promL2R2_nucldur promL2R2_nucldur
;  Set column label (index)... promL2_sylldur promL2_sylldur
;  Set column label (index)... promL3_sylldur promL3_sylldur
;  Set column label (index)... promL2R2_sylldur promL2R2_sylldur
;  Set column label (index)... promL2R1_sylldur promL2R1_sylldur
;  Set column label (index)... promL3R1_sylldur promL3R1_sylldur
;  Set column label (index)... promL2R2_loudness promL2R2_loudness
endproc


procedure save_spreadsheet
   select nucldatID
; Remove columns from right to left!
   Remove column (index)... endtime_syll
   Remove column (index)... j_before_pause
   Remove column (index)... j_hesitation
   Remove column (index)... promL2R1D_f0_mean
   Remove column (index)... promL2R1D_rimedur
   Remove column (index)... promL2R1D_sylldur
   Remove column (index)... promL2R1D_nucldur
   Remove column (index)... loudness
   Remove column (index)... intrasyllab
   ; Remove column (index)... j_rimedur
   ; Remove column (index)... syll_dur
   Write to headerless spreadsheet file... 'sheetfile$'
endproc


procedure safe_nuclei start_time_n end_time_n
# Adjust nuclei boundaries such that they are all voiced and pitch is defined
# Return in <result> the number of valid nuclei in analysis interval
   mindur_syl = 0.01	; minimum duration for syllable, otherwise skipped
   call interval_from_time nucleiID nucleus_tier start_time_n first_interval
   select nucleiID
   iNucl = first_interval
   prev_boundary = Get start point... safe_tier 1
   x1 = Get start point... nucleus_tier iNucl
   repeat
      select nucleiID
      iNucl = Get interval at time... nucleus_tier x1	; nrof intervals may change during process
      x1 = Get start point... nucleus_tier iNucl
      x2 = Get end point... nucleus_tier iNucl
      label$ = Get label of interval... nucleus_tier iNucl
      if (label$ = "a") ; "a" indicates syllabic nucleus, i.e. interval on which to apply stylization
         call defined_intersection pitchID x1 x2
         cx1 = result1
         cx2 = result2
;printline safe_nuclei: after defined_intersection x1='x1:4' x2='x2:4' cx1='cx1:4' cx2='cx2:4' result='result'
	 select nucleiID
         if (result == 0)	; nucleus fully undefined
            Set interval text... nucleus_tier iNucl undef
         else
            if (cx1 > x1)	; undefined section at start of nucleus
               Insert boundary... nucleus_tier cx1
               Set interval text... nucleus_tier iNucl xL
               Set interval text... nucleus_tier iNucl+1 a
               iNucl += 1
            endif
	    call octavejump nucleiID pitchID cx1 cx2
            cx1 = result1	; update safe interval
            cx2 = result2	; idem
;printline safe_nuclei: after octavejump cx1='cx1:4' cx2='cx2:4' result='result'
            select nucleiID
            if (result = 0)		; interval too short
               Set interval text... nucleus_tier iNucl short
            elsif (result3 == 1)	; discontinuity found
	       Insert boundary... nucleus_tier cx2
               Set interval text... nucleus_tier iNucl a
               Set interval text... nucleus_tier iNucl+1 skip
            elsif (cx2-cx1 < mindur_syl)
               Set interval text... nucleus_tier iNucl short
            elsif (cx2 < x2)
               Insert boundary... nucleus_tier cx2
               j = Get interval at time... nucleus_tier cx2
               Set interval text... nucleus_tier j xR
               Set interval text... nucleus_tier j-1 a
	    endif
	    if (cx2-cx1 >= mindur_syl)		; safe_tier
               if (cx1 > prev_boundary)
                  Insert boundary... safe_tier cx1
               endif
               Insert boundary... safe_tier cx2
               prev_boundary = cx2
               j = Get interval at time... safe_tier cx1+(cx2-cx1)/2
               Set interval text... safe_tier j a
            endif
	 endif
      endif ; label="a"
      x1 = x2
; next line required because of rounding errors !
      intervals = Get number of intervals... nucleus_tier
   until (x2 >= end_time_n or iNucl = intervals)

   select nucleiID
   nn = Count labels... nucleus_tier a
   result = nn			; number of nuclei for analysis
endproc


procedure stylize_nuclei start_time_n end_time_n
   tier = nucleus_tier
   mindur_syl = 0.01	; minimum duration for syllable, otherwise skipped
   call interval_from_time nucleiID tier start_time_n first_interval
   call interval_from_time nucleiID tier end_time_n last_interval

   select nucleiID
   nrofnuclei = Get number of intervals... tier
   if (not reuse_nucl)
      call copy_tier nucleiID nucleus_tier nucleiID pointer_tier
      call tier_clear_text nucleiID pointer_tier
   endif

   ; fill some columns in table nucldatID 
   nucleus_ctr = 0		; counter for row
   for iNucl from first_interval to last_interval
      select nucleiID
      label$ = Get label of interval... tier iNucl
      if (label$ = "a") ; "a" indicates syllabic nucleus, i.e. interval on which to apply stylization
         x1 = Get start point... tier iNucl
         x2 = Get end point... tier iNucl
         nucleus_ctr += 1
         select nucleiID
         Set interval text... pointer_tier iNucl 'nucleus_ctr'
         select nucldatID
         Set row label (index)... nucleus_ctr 'x1:3'
         s$ = fixed$(x1,3)
         Set value... nucleus_ctr nucleusstarttime 's$'
         s$ = fixed$(x2,3)
         Set value... nucleus_ctr nucleusendtime 's$'
         s$ = fixed$(x2-x1,5)
         Set value... nucleus_ctr nucleusdur 's$'
         Set value... nucleus_ctr j_voweldur 0
         Set value... nucleus_ctr j_syllabledur 0
         Set value... nucleus_ctr j_rimedur 0
      endif
   endfor
   ; calculate gap between successive nuclei to locate pauses
   select nucldatID
   mindur_pause_gap = 0.35		; min duration for gap between nuclei for pause 
   for j to nrof_nuclei_analysed
      x2 = Get value... j nucleusendtime
      if (j < nrof_nuclei_analysed)
         x1 = Get value... j+1 nucleusstarttime
      else
         x1 = x2 + 1
      endif
      if (x1-x2 >= mindur_pause_gap)
         Set value... j j_before_pause 1
      else
         Set value... j j_before_pause 0
      endif
   endfor

   prev_nucleus = 0	; index (into textgrid tier) of previous nucleus; 0 indicates "not found"
   for iNucl from first_interval to last_interval
      select nucleiID
      label$ = Get label of interval... tier iNucl
      if (label$ = "a") ; "a" indicates nucleus, i.e. interval to apply stylization on
         x1 = Get start point... tier iNucl
         x2 = Get end point... tier iNucl
         call stylize_nucleus iNucl x1 x2
      endif
   endfor

   if (phones_available)	; calculate vowel duration for spreadsheet
      call calc_vowel_duration nucldatID j_voweldur
      call calc_nPVI nucldatID j_voweldur
   endif
   if (syllables_available and phones_available and segm_type <> segm_asyll) ; calculate syllable duration for spreadsheet
      call calc_rime_duration nucldatID j_rimedur
   endif
endproc


procedure defined_intersection paramID t1 t2
# Find region within <t1>..<t2> for which parameter is defined
# Returns <result> = 0 when fully undefined
# Returns <result1> and <result2>, the defined interval
   result = 1
   result1 = t1
   result2 = t2
   select paramID
   dx = Get time step
   ok = 0
   t = t1
   while (ok == 0 and t <= t2)		; go right while undefined
      y = Get value at time... t Hertz Linear
      if (y == undefined)
         t += dx 
      else
         ok = 1
      endif
      result1 = t
   endwhile
   if (t > t2)
      result = 0
   else
      while (ok == 1 and t <= t2)	; go right while defined
         y = Get value at time... t Hertz Linear
         if (y == undefined)
            ok = 0
         else
            result2 = t
            t += dx 
         endif
      endwhile
      if (result1 >= t2)
         result = 0
      endif
   endif
endproc


procedure octavejump nuclID paramID t1 t2
# Find region within <t1>..<t2> for which pitch does not present discontinuities such as octave jumps
# Returns result = 0 when left with too short segment
# Returns result = 1 when OK
# Returns result1 and result2, the safe interval
# Returns result3 = 1 when discontinuity found, in which case <result2> is end of safe interval
# Stores position of discontinuity in (point) tier <discontinuity_tier> of <nuclID>
   result3 = 0			; no discontinuity found
   select paramID
   dx = Get time step
   ok = 1
   t = t1
   f1 = Get value at time... t Hertz Linear
   while (ok == 1 and t <= t2)
      select paramID
      f2 = Get value at time... t Hertz Linear
      if (abs(f2-f1)/min(f1,f2) > 0.3)	; was 0.2 initially and 0.5 in v2.7g
         ok = 0
         result3 = 1		; discontinuity found
	 select nuclID
         Insert point... discontinuity_tier t
      else
         result2 = t
         t += dx
         f1 = f2
      endif
   endwhile
   result = 1
   if (result2 - t1 <= dx)
      result = 0
   endif
   result1 = t1
endproc


procedure stylize_nucleus iNucl x1 x2
# <x1>..<x2>	times of interval to stylize

   xmid = x1 + (x2-x1)/2
   select nucleiID
   i_ = Get interval at time... pointer_tier xmid
   s$ = Get label of interval... pointer_tier i_
   nucleus_ctr = 's$'		; index of row in table nucldatID
   select nucldatID
   pause_follows = Get value... nucleus_ctr j_before_pause
   glissando_local = glissando
   if (adaptive_glissando and pause_follows)
      glissando_local = glissando_low
   endif

# Step 1. Find turning points (TP) in contour, by order of importance.
# A TP is the point where the distance between the actual F0 and the linear fit of F0 values is largest.
# A TP is kept only if the difference in slope between the parts before and after 
# the TP exceeds the differential glissando threshold, and if at least 1 of the parts is an audible pitch movement.
# When a TP is found, additional TPs are searched for in the left part, until none are found.
# Then the search continues for the interval between the last TP and the end of the nucleus interval.
   nrofts = 1				; number of tonal segments
   select stylID
   Add point... x1 1
   Add point... x2 1
   i1 = Get nearest index from time... x1
   xL = x1				; xL..xR is time window under analysis
   xR = x2
;printline stylize nucleus='iNucl' start x1='x1:3' x2='x2:3' mindur_ts='mindur_ts:3'
   repeat
;printline stylize nucleus='iNucl' repeat1 xL='xL:3' xR='xR:3' mindur_ts='mindur_ts:3'
      nrofsplit = 0			; nrof turning points found in repeat loop 
      repeat				; find turning points
;printline stylize nucleus='iNucl' start xL='xL:3' xR='xR:3'
         split = 0			; nrof times split at turning point
         call is_audible "aud_A" xL xR
;printline stylize-2 xL='xL:3' xR='xR:3' AUD='aud_A' nrofts='nrofts'
	 if (aud_A)
            call turning_point xL xR
;printline stylize-3 maxdiftime='maxdiftime'
	    if (maxdiftime >= 0)	; found turning point
;d1 = maxdiftime - xL
;d2 = xR - maxdiftime
;printline stylize-4 leftpart='d1:3' rightpart='d2:3'
               if ((maxdiftime - xL >= mindur_ts) and (xR - maxdiftime >= mindur_ts))
                  call is_audible "aud_L" xL maxdiftime
	          g1 = slopeSTs		; slope (ST/s) for part left of turning point
	          call is_audible "aud_R" maxdiftime xR
                  g2 = slopeSTs		; slope (ST/s) for part right of turning point
;printline AUD_L='aud_L' slope='g1:2' AUD_R='aud_R' slope='g2:2'
                  if ((abs (g2-g1) > diffgt) and (aud_L or aud_R) )  
                     split = 1		; found a valid turning point 
                  endif
               endif
            endif
;printline stylize-5 nucleus='iNucl' split='split'
            if (split)	       
;printline stylize-5b nucleus='iNucl' split at t='maxdiftime:3'
	       select stylID
               Add point... maxdiftime 1
               xR = maxdiftime
               nrofsplit += 1		; turning points inserted in this loop
	       nrofts += 1		; additional tonal segment found
            endif
         endif
      until (split = 0)
      if (xR < x2)			; interval was split; continue segmentation for right side
         i1 += 1			; adjust xL..xR analysis window
         select stylID
	 xL = Get time from index... i1
	 xR = Get time from index... i1+1
;printline stylize-6 continue from t='xL:3'
      else				; no split...
         nrofsplit = 0			; prepare for end of repeat loop
         xL = x2
      endif
   until (nrofsplit == 0 and xL >= x2)

# Step 2. Actual stylisation
   cum_intra = 0		; cumulated intrasyllabic pitch variation
   cum_intra_up = 0		; sum of intrasyllabic pitch rises
   cum_intra_down = 0		; sum of intrasyllabic pitch falls
   cum_abs_intra = 0		; cumulated absolute intrasyllabic pitch variation
   dynamic_type = 0		; dynamic_type, 0 = static, 1 = rising, -1 = falling
   dynamic_up = 0
   dynamic_down = 0
   select stylID
   i = Get nearest index from time... x1
   i2 = Get nearest index from time... x2
   ts = 1			; index of tonal segment under analysis
   while (i < i2)		; for each tonal segment
      select stylID
      xL = Get time from index... i
      xR = Get time from index... i+1
      call is_audible "aud_A" xL xR
      intST = dist		; pitch interval (in ST) in current tonal segment
      cum_intra += intST
      cum_abs_intra += abs (intST)
      cum_intra_up += max (intST, 0)
      cum_intra_down += min (intST, 0)
      # Check special case of two inaudible parts. e.g. bell-shaped contour
      if (aud_A = 1 and nrofts = 1)
;printline Check special case xL='xL:3' xR='xR:3'
            call turning_point xL xR
;printline special_case maxdiftime='maxdiftime:3'
	    if (maxdiftime >= 0)	; turning point found
               call is_audible "aud_L" xL maxdiftime
	       g1 = slopeSTs
               call is_audible "aud_R" maxdiftime xR
               g2 = slopeSTs
               d1 = maxdiftime - xL
               d2 = xR - maxdiftime
;printline AUD_L='aud_L' slope='g1:2' AUD_R='aud_R' slope='g2:2'
               if (aud_L == 0 and aud_R == 0)  
                  if ((g1 > 0 and g2 < 0) or (g1 < 0 and g2 > 0))  
                     aud_A = 0	; consider inaudible
                     intST = 0
	          endif
	       endif
            endif
      endif ; special case
      select pitchID
      yR = Get value at time... xR Hertz Linear
      yL = Get value at time... xL Hertz Linear
      yM = Get quantile... xL xR 0.5 Hertz
;printline xL='xL:3' yL='yL:3' xR='xR:3' yR='yR:3' yM='yM:3'
      select stylID
      if (ts = 1)		; first tonal segment of nucleus => also set value at start
	 if (aud_A = 0)
            yR = yM		; normalize pitch to modal pitch
            yL = yR
         endif
         Remove point... i	; to replace value of point at xL
	 Add point... xL yL	; set Y value of turning point at xL
         pv_lo = min (yL, yR)
         pv_hi = max (yL, yR)
         pv_start = yL
      endif
      Remove point... i+1	; to replace value of point at xR
      Add point... xR yR	; set Y value of turning point at xR
      if (aud_A)
         distST = 12 * log2 (yR/yL)
         if (distST > 0)
            dynamic_up += intST
         else
            dynamic_down += intST
         endif
         dynamic_type = 1
      endif
      pv_lo = min (pv_lo, yR)
      pv_hi = max (pv_hi, yR)
      ts += 1
      i += 1
   endwhile
   if (dynamic_type == 1)
      if (abs(dynamic_down) > dynamic_up)
         dynamic_type = -1
      endif
   endif
   select pitchID
   v_f0_min = Get minimum... x1 x2 Hertz Parabolic
   v_f0_max = Get maximum... x1 x2 Hertz Parabolic
   pv_median = Get quantile... x1 x2 0.50 Hertz
   pv_mean = Get mean... x1 x2 semitones re 1 Hz
   if (prev_nucleus > 0)	; already found a nucleus in left context
      call distST prev_f0_end pv_start
      select nucleiID
      prev_x2 = Get end point... nucleus_tier prev_nucleus
   else				; first nucleus in analysis window
      prev_x2 = anal_t1
      distST = 0
   endif
   if (syllables_available)
      select nucleiID
      imid = Get interval at time... syllable_tier xmid
      syllt1 = Get start point... syllable_tier imid
      syllt2 = Get end point... syllable_tier imid
      sylldur = syllt2 - syllt1
   else
      sylldur = undefined
      syllt2 = undefined
   endif
; Store all parameters for syllable in table
   select nucldatID
   Set value... nucleus_ctr f0_start floor(pv_start)
   Set value... nucleus_ctr f0_end floor(yR)
   Set value... nucleus_ctr f0_min floor(v_f0_min)
   Set value... nucleus_ctr f0_max floor(v_f0_max)
   Set value... nucleus_ctr f0_median floor(pv_median)
   ; s$ = fixed$(pv_mean,3)
   Set value... nucleus_ctr f0_mean floor(pv_mean)
   Set value... nucleus_ctr lopitch floor(pv_lo)
   Set value... nucleus_ctr hipitch floor(pv_hi)
   Set value... nucleus_ctr dynamic dynamic_type
   s$ = fixed$(cum_intra,3)
   Set value... nucleus_ctr intrasyllab 's$'
   s$ = fixed$(cum_intra_up,3)
   Set value... nucleus_ctr intrasyllabup 's$'
   s$ = fixed$(cum_intra_down,3)
   Set value... nucleus_ctr intrasyllabdown 's$'
   s$ = fixed$(distST,3)
   Set value... nucleus_ctr intersyllab 's$'
   s$ = fixed$(cum_abs_intra,3)
   Set value... nucleus_ctr trajectory 's$'
; internucleusdur = time between end of previous nucleus and start of current one
   s$ = fixed$((x1 - prev_x2),3)
   Set value... nucleus_ctr internucleusdur 's$'
   if (syllables_available)
      s$ = fixed$(sylldur,4)
      Set value... nucleus_ctr j_syllabledur 's$'
   endif
;   endtime_syll: used by plot_salience (only for appropriate segmentation method)
   Set value... nucleus_ctr endtime_syll syllt2
   if (include_loudness and loudness_available)
      select loudnessID
      v = Get maximum... x1 x2 None
      s$ = fixed$(v,3)
      select nucldatID
      Set value... nucleus_ctr loudness 's$'
   endif
   select intensityID
   v = Get maximum... x1 x2 None
   s$ = fixed$(v,1)
   select nucldatID
   Set value... nucleus_ctr j_int_peak 's$'
   prev_f0_end = yR			; save f0_end for next syllable
   prev_nucleus = iNucl			; used for next nucleus
   prev_nucleus_ctr = nucleus_ctr	; used for next nucleus
   last_x2 = x2				; used for last nucleus
endproc


procedure distST f1 f2
   distST = 12 * log2 (f2/f1)
endproc


procedure slopeSTs first last
# Calculate slope of F0 variation (in ST/s) in time interval <first>..<last>
# Return slope in variable 'slopeSTs'.
# Return pitch intervak (in ST) in variable 'dist'
   select pitchID
   max = Get maximum... first last Hertz None
   min = Get minimum... first last Hertz None
   tmax = Get time of maximum... first last Hertz None
   tmin = Get time of minimum... first last Hertz None
   if (tmin <= tmax) 
      dist = 12 * log2 (max/min)
   else 
      dist = 12 * log2 (min/max)
   endif
   slopeSTs = dist / (last-first)
endproc


procedure is_audible varname$ first last
# Evaluate audibility of pitch change for frequency values (in Hz)
# and store boolean result in variable with name 'varname$'
   duration = last-first
   call slopeSTs first last
   if (abs (slopeSTs) >= glissando_local/(duration*duration))
      'varname$' = 1
   else 
      'varname$' = 0
   endif
endproc


procedure turning_point first last
# Find most important turning point.
# returns <maxdiftime> = time of turning point in time interval <first>..<last>
# returns -1 if max difference too small ( < 1 ST ) 
   select pitchID
   dx = Get time step
   q1 = Get frame number from time... first
   f0_x1 = Get value in frame... q1 Hertz
   if (f0_x1 == undefined)
      x1_time = Get time from frame... q1
      call fatal_error turning_point: Pitch undefined at (left boundary) time='x1_time' first='first' last='last' q1='q1' q2='q2' 
   endif
   q2 = Get frame number from time... last
   f0_x2 = Get value in frame... q2 Hertz
   if (f0_x2 == undefined)
      x2_time = Get time from frame... q2
      call fatal_error turning_point: Pitch undefined at (right boundary) time='x2_time' first='first' last='last' q1='q1' q2='q2' 
   endif
   a = f0_x1
   b = (f0_x2 - f0_x1) / ((q2-q1)*dx)
   maxdif = 0
   maxdiffit = 1
   maxdiftime = first
   maxdifq = q1
   for q from q1 to q2
      fit = a + b * ((q-q1)*dx)
      f0_x = Get value in frame... q Hertz
      if (f0_x == undefined)
         time = Get time from frame... q
	 call fatal_error turning_point: Pitch undefined at time='time:4' first='first' last='last' q1='q1' q2='q2' 
      endif
      dy = abs (f0_x - fit)
      if (dy > maxdif)
         maxdif = dy
	 maxdifq = q
	 maxdiffit = fit
      endif
   endfor
   if (maxdif = 0)
      maxdiftime = -1
   elsif (abs(12 * log2 (maxdif/maxdiffit)) < 1)	; smaller than 1 ST 
      maxdiftime = -1
   else
      maxdiftime = Get time from frame... maxdifq
   endif
endproc


procedure calc_vowel_duration table dst
# <dst>		column where results are stored
   select table
   rows = Get number of rows
   for row to rows	; for each nuclei in the signal
      s_$ = ""
      select table
      Set value... row dst 0
      x1 = Get value... row nucleusstarttime
      x2 = Get value... row nucleusendtime
      xmid = x1 + (x2-x1)/2
      select nucleiID
      if (syllables_available and phones_available)
         i_ = Get interval at time... syllable_tier xmid
         s_$ = Get label of interval... syllable_tier i_ 
         x1 = Get start point... syllable_tier i_
         x2 = Get end point... syllable_tier i_
         i = Get interval at time... phone_tier x1
         i2 = Get interval at time... phone_tier x2
         repeat
            select nucleiID
            label$ = Get label of interval... phone_tier i 
            call is_vowel 'label$'
            if (is_vowel)
               x1 = Get start point... phone_tier i
               x2 = Get end point... phone_tier i
            elsif (i+1 == i2)
               call msg No vowel in syllable <'s_$'> at 'xmid:3'
               ; use syllable duration
            endif
            i += 1
         until (is_vowel or i == i2)
      elsif (phones_available)
         i = Get interval at time... phone_tier xmid
         label$ = Get label of interval... phone_tier i 
         call is_vowel 'label$'
         if (is_vowel)
            x1 = Get start point... phone_tier i
            x2 = Get end point... phone_tier i
         endif
      endif
      select table
      s_$ = fixed$(x2-x1,4)
      Set value... row dst 's_$'
   endfor
endproc


procedure calc_rime_duration table dst
# <dst>		column where results are stored
   select table
   rows = Get number of rows
   for j to rows ; nrof_nuclei_analysed
      Set value... j j_rimedur undefined	; prepare for possible error in annotation or lacking annotation
   endfor
   for j to nrof_nuclei_analysed		; calculate rime duration
         select table
         x1 = Get value... j nucleusstarttime
         call interval_from_time nucleiID syllable_tier x1 syll
         syll_x1 = Get start point... syllable_tier syll
         syll_x2 = Get end point... syllable_tier syll
         call interval_from_time nucleiID phone_tier syll_x1 ph1
         call interval_from_time nucleiID phone_tier syll_x2-0.001 ph2
         phon = ph1
         nrof_syllabics = 0
         repeat
            label$ = Get label of interval... phone_tier phon
            call is_syllabic 'label$'
            if (result)
               phon_x1 = Get start point... phone_tier phon
               select table
               s_$ = fixed$(syll_x2-phon_x1,4)
               Set value... j dst 's_$'
               nrof_syllabics += 1
            endif
            phon += 1
         until (result or phon > ph2)
         if (nrof_syllabics == 0)
            call msg calc_rime_duration: Syllable without syllabic sound at time 'syll_x1:3'
         endif
   endfor
endproc


procedure calc_nPVI table src
# Calculate Normalized Pairwise Variability Index on data in <table>
# <src>		column where values are taken from
# <result>	nPVI for all data in src
   select table
   rows = Get number of rows
   sum = 0
   if (rows > 1)
      for row from 2 to rows	; for each nucleus in the signal
         y = Get value... row src
         y1 = Get value... row-1 src 
         sum += abs( (y1 - y) / ((y1 + y)/2) )
      endfor
   endif
   result = 100*sum/(rows-1)
endproc


procedure create_table_global_report
# Create variables for global report, showing results for all input files
    j_speech_time = 1
    propphonation = 2
    proppause = 3
    j_speech_rate = 4
    ;meannucldur = 5
    j_pitch_range = 5
    j_pitch_top = 6
    j_pitch_bottom = 7
    j_pitch_median = 8
    j_pitch_mean = 9
    j_prop_gliss = 10
    j_prop_rises = 11
    j_prop_falls = 12
    j_rate_traj_intra = 13
    j_rate_traj_inter = 14
    j_rate_traj_phon = 15
    j_rate_traj_intra_z = 16
    j_rate_traj_inter_z = 17
    j_rate_traj_phon_z = 18
    j_nPVI = 19
    f0_qu02 = 20
    f0_qu05 = 21
    f0_qu50 = 22
    f0_qu95 = 23
    f0_qu98 = 24
    sp_qu02 = 25
    sp_qu05 = 26
    sp_qu50 = 27
    sp_qu95 = 28
    sp_qu98 = 29

    Create TableOfReal... report nrofFiles 29
    reportID = selected ("TableOfReal",-1)
    Set column label (index)... j_speech_time SpeechTime
    Set column label (index)... propphonation propphonation 
    Set column label (index)... proppause proppause 
    Set column label (index)... j_speech_rate SpeechRate 
    ;Set column label (index)... meannucldur meannucldur 
    Set column label (index)... j_pitch_range PitchRange 
    Set column label (index)... j_pitch_top PitchTop
    Set column label (index)... j_pitch_bottom PitchBottom
    Set column label (index)... j_pitch_median PitchMedian 
    Set column label (index)... j_pitch_mean PitchMean 
    Set column label (index)... j_prop_gliss Gliss 
    Set column label (index)... j_prop_rises Rises 
    Set column label (index)... j_prop_falls Falls 
    Set column label (index)... j_rate_traj_intra TrajIntra 
    Set column label (index)... j_rate_traj_inter TrajInter
    Set column label (index)... j_rate_traj_phon TrajPhon
    Set column label (index)... j_rate_traj_intra_z TrajIntraZ 
    Set column label (index)... j_rate_traj_inter_z TrajInterZ
    Set column label (index)... j_rate_traj_phon_z TrajPhonZ
    Set column label (index)... j_nPVI nPVI
    Set column label (index)... f0_qu02 f0_qu02
    Set column label (index)... f0_qu05 f0_qu05
    Set column label (index)... f0_qu50 f0_qu50
    Set column label (index)... f0_qu95 f0_qu95
    Set column label (index)... f0_qu98 f0_qu98
    Set column label (index)... sp_qu02 sp_qu02
    Set column label (index)... sp_qu05 sp_qu05
    Set column label (index)... sp_qu50 sp_qu50
    Set column label (index)... sp_qu95 sp_qu95
    Set column label (index)... sp_qu98 sp_qu98
endproc


procedure prosodic_profile
 if (nrof_nuclei_analysed == 0)
   filedelete 'statsfile$'
   fileappend 'statsfile$' Prosodic profile for input file: 'signalfile$'
   fileappend 'statsfile$' The prosodic profile could not be calculated because no nuclei were detected.'newline$'
   call msg Prosodic profile not calculated: no nucleu detected in speech signal.
 elsif (not needs_pitchrange)
   filedelete 'statsfile$'
   fileappend 'statsfile$' Prosodic profile for input file: 'signalfile$'
   fileappend 'statsfile$' Prosodic profile calculation requires selection of full time range of speech signal. 'newline$'
   call msg Prosodic profile not calculated: requires selection of full time range of signal.
 else ; nrof_nuclei_analysed > 0 and pitchrange calculated
   min_pause_duration = 0.3
   select nucldatID
   nrof_nucl = Get number of rows
   sum_nucldur = 0
   sum_internucldur = 0	; time between nuclei, corrected for pauses
   sum_gapdur = 0	; time of pauses

   for j from 1 to nrof_nucl
      x1$ = Get row label... j
      sum_nucldur += Get value... j nucleusdur
      v_ind = Get value... j internucleusdur
      if (v_ind >= min_pause_duration)		; pause to LEFT of current nucleus
	 sum_gapdur += v_ind
      else
         sum_internucldur += v_ind
      endif
   endfor
   total_dur      = anal_t2 - anal_t1
   phonation_time = sum_internucldur + sum_nucldur
   speech_time    = phonation_time + sum_gapdur
   prop_pause     = 100 * sum_gapdur / speech_time
   prop_phonation = 100 * phonation_time / speech_time
   speech_rate    = nrof_nucl / phonation_time

# Compute quantiles of f0_min and f0_max values of each nucleus before stylization
   tmptableID = Create Table without column names... pitchvalues nrof_nucl*2 1
   Set column label (index)... 1 pitchvalue
   for j from 1 to nrof_nucl
      select nucldatID
      vlo = Get value... j f0_min
      vhi = Get value... j f0_max
      select tmptableID
      Set numeric value... j pitchvalue vlo
      Set numeric value... (nrof_nucl+j) pitchvalue vhi
   endfor
   rpqu50 = Get quantile... pitchvalue 0.5
   rpqu05 = Get quantile... pitchvalue 0.05
   rpqu95 = Get quantile... pitchvalue 0.95
   rpqu02 = Get quantile... pitchvalue 0.02
   rpqu98 = Get quantile... pitchvalue 0.98
   select tmptableID
   Remove

# Compute quantiles of lo and hi pitch values of each nucleus after stylization
   tmptableID = Create Table without column names... pitchvalues nrof_nucl*2 1
   Set column label (index)... 1 pitchvalue
   for j from 1 to nrof_nucl
      select nucldatID
      vlo = Get value... j lopitch
      vhi = Get value... j hipitch
      select tmptableID
      Set numeric value... j pitchvalue vlo
      Set numeric value... (nrof_nucl+j) pitchvalue vhi
   endfor
   spqu50 = Get quantile... pitchvalue 0.5
   spqu05 = Get quantile... pitchvalue 0.05
   spqu95 = Get quantile... pitchvalue 0.95
   spqu02 = Get quantile... pitchvalue 0.02
   spqu98 = Get quantile... pitchvalue 0.98
   select tmptableID
   Remove


   date_$ = date$ ()
call msg Writing prosodic profile to: 'statsfile$'
   filedelete 'statsfile$'
   w$ = "fileappend ""'statsfile$'"" 'newline$'"
   'w$' Prosodic profile for input file: 'signalfile$'
   'w$'
   'w$' Date: 'date_$'
   'w$' Segmentation type: 'segmentation_name$'
   'w$' Time:  
   'w$'     total speech time        ='speech_time:2' s (= internucleus time + intranucleus time + pause time)
   'w$'     estimated phonation time ='phonation_time:2' ('prop_phonation:2'% of speech time) (= internucleus time + intranucleus time)
   'w$'     estimated pause time     ='sum_gapdur:2' ('prop_pause:2'% of speech time) (= when internucleus time >= 'min_pause_duration')
   'w$'     estimated speech rate    ='speech_rate:2' (nrof_nuclei/phonation_time)

   'w$' Nucleus: 'nrof_nucl' nuclei in signal
   if (nrof_nucl < 100)
      'w$' 'newline$' WARNING: The global measures below are only meaningful for speech samples of at least 100 nuclei (syllables).'newline$'
   endif
   select nucldatID
   mean_nucldur = Get column mean (label)... nucl_dur
   stdev_nucldur = Get column stdev (label)... nucl_dur
   'w$' Duration: 
   'w$'     Nucleus duration: 
   'w$'        mean='mean_nucldur:3'(s) stdev='stdev_nucldur:3' summed nucleus duration='sum_nucldur:2'(s)
   call calc_nPVI nucldatID nucleusdur
   nPVI_nucldur = result
   'w$'     nPVI (nucleus duration)='result:0' (assumes there's only 1 speaker)
   if (syllables_available)
      call calc_nPVI nucldatID j_syllabledur
     'w$'     nPVI (syllable duration)='result:0' (assumes there's only 1 speaker)
   endif
   if (phones_available)
      call calc_vowel_duration nucldatID j_voweldur
      call calc_nPVI nucldatID j_voweldur
     'w$'     nPVI (vowel duration)='result:0' (assumes there's only 1 speaker)
   endif

   'w$' Global pitch measures: 
   'w$'     Quantiles of min and max F0 values of nuclei before stylisation: 
   'w$'       2%='rpqu02:0'Hz, 5%='rpqu05:0'Hz, 50%='rpqu50:0'Hz, 95%='rpqu95:0'Hz, 98%='rpqu98:0'Hz 
   'w$'     Quantiles of low & high pitch values of nuclei after stylisation: 
   'w$'       2%='spqu02:0'Hz, 5%='spqu05:0'Hz, 50%='spqu50:0'Hz, 95%='spqu95:0'Hz, 98%='spqu98:0'Hz 

   call pitchrange_speakers_report
   'w$' 'result$'

   'w$' Intrasyllabic pitch interval: 
   speaker_j=1
   prop_gliss = extractNumber (speaker_profile_'speaker_j'$, "GLISS=")
   prop_rises = extractNumber (speaker_profile_'speaker_j'$, "RISES=")
   prop_falls = extractNumber (speaker_profile_'speaker_j'$, "FALLS=")
   'w$'     large='prop_gliss:2'% (>= 4 ST), rises='prop_rises:2'%, falls='prop_falls:2'%
   select nucldatID
   ;mean = Get column mean (label)... intrasyllab
   ;stdev = Get column stdev (label)... intrasyllab
   ;'w$'     mean='mean:2'(ST) stdev='stdev:2'
   v = extractNumber (speaker_profile_'speaker_j'$, "TRAJ_INTRA_RATE=")
   z = extractNumber (speaker_profile_'speaker_j'$, "TRAJ_INTRA_Z_RATE=")
   'w$'     trajectory/nucleus_time='v:2' ST/s or 'z:2' sd/s

   'w$' Intersyllabic pitch interval: 
   ;mean = Get column mean (label)... intersyllab
   ;stdev = Get column stdev (label)... intersyllab
   ;'w$'     mean='mean:2'(ST) stdev='stdev:2'
   v = extractNumber (speaker_profile_'speaker_j'$, "TRAJ_INTER_RATE=")
   z = extractNumber (speaker_profile_'speaker_j'$, "TRAJ_INTER_Z_RATE=")
   'w$'     trajectory/inter_nucleus_time='v:2' ST/s or 'z:2' sd/s

   'w$' All pitch intervals: 
   v = extractNumber (speaker_profile_'speaker_j'$, "TRAJ_PHON_RATE=")
   z = extractNumber (speaker_profile_'speaker_j'$, "TRAJ_PHON_Z_RATE=")
   'w$'     trajectory(phonation)/phonation_time='v:2' ST/s or 'z:2' sd/s
   'w$'

   call pitchprofile_speakers_report
   'w$' 'result$'
   'w$'

'w$' SpeechTime = total speech time (in s) = internucleus time + intranucleus time + pause time
'w$' PhonTime   = phonation time (in s) = without pauses = internucleus time + intranucleus time
'w$' PropPhon   = proportion (%) of estimated phonation time (= internucleus time + intranucleus time) to speech time
'w$' PropPause  = proportion (%) of estimated pause time (= when internucleus time >= 0.3) to speech time
'w$' SpeechRate = estimated speech rate (in syll/s) = nrof_nuclei/phonation_time
'w$' PitchRange = estimated pitch range (in ST) (2%-98% percentiles of data in nuclei without discontinuities)
'w$' Gliss      = proportion (%) of syllables with large pitch movement (abs(distance) >= 4ST)
'w$' Rises      = proportion (%) of syllables with pitch rise (>= 4ST)  
'w$' Falls      = proportion (%) of syllables with pitch fall (<= -4ST)
'w$' TrajIntra  = pitch trajectory (sum of absolute intervals) within syllabic nuclei, divided by duration (in ST/s) 
'w$' TrajInter  = pitch trajectory (sum of absolute intervals) between syllabic nuclei (except pauses or speaker turns), divided by duration (in ST/s) 
'w$' TrajPhon   = sum of TrajIntra and TrajInter, divided by phonation time (in ST/s) 
'w$' TrajIntraZ = as TrajIntra, but for pitch trajectory in standard deviation units on ST scale (z-score) (in sd/s) 
'w$' TrajInterZ = as TrajInter, but for pitch trajectory in standard deviation units on ST scale (z-score) (in sd/s)
'w$' TrajPhonZ  = as TrajPhon,  but for pitch trajectory in standard deviation units on ST scale (z-score) (in sd/s)
'w$'

# store some values for the global profile spreadsheet (covering multiple speech files) 
   select reportID
   Set row label (index)... iFile "'basename$'"
   Set value... iFile j_speech_time 'speech_time:2'
   Set value... iFile propphonation 'prop_phonation:2'
   Set value... iFile proppause 'prop_pause:2'
   Set value... iFile j_speech_rate 'speech_rate:2'
   v = extractNumber (speaker_range_1$, "RANGE_ST=")
   Set value... iFile j_pitch_range 'v:1'
   v = extractNumber (speaker_range_1$, "TOP_Hz=")
   Set value... iFile j_pitch_top 'v:0'
   v = extractNumber (speaker_range_1$, "BOTTOM_Hz=")
   Set value... iFile j_pitch_bottom 'v:0'
   v = extractNumber (speaker_range_1$, "MEDIAN_Hz=")
   Set value... iFile j_pitch_median 'v:0'
   v = extractNumber (speaker_range_1$, "MEAN_Hz=")
   Set value... iFile j_pitch_mean 'v:0'
   Set value... iFile j_nPVI 'nPVI_nucldur:2'
   speaker_j=1
   v = extractNumber (speaker_profile_'speaker_j'$, "GLISS=")
   Set value... iFile j_prop_gliss 'v:2'
   v = extractNumber (speaker_profile_'speaker_j'$, "RISES=")
   Set value... iFile j_prop_rises 'v:1'
   v = extractNumber (speaker_profile_'speaker_j'$, "FALLS=")
   Set value... iFile j_prop_falls 'v:2'
   v = extractNumber (speaker_profile_'speaker_j'$, "TRAJ_INTRA_RATE=")
   Set value... iFile j_rate_traj_intra 'v:2'
   v = extractNumber (speaker_profile_'speaker_j'$, "TRAJ_INTER_RATE=")
   Set value... iFile j_rate_traj_inter 'v:2'
   v = extractNumber (speaker_profile_'speaker_j'$, "TRAJ_PHON_RATE=")
   Set value... iFile j_rate_traj_phon 'v:2'
   v = extractNumber (speaker_profile_'speaker_j'$, "TRAJ_INTRA_Z_RATE=")
   Set value... iFile j_rate_traj_intra_z 'v:2'
   v = extractNumber (speaker_profile_'speaker_j'$, "TRAJ_INTER_Z_RATE=")
   Set value... iFile j_rate_traj_inter_z 'v:2'
   v = extractNumber (speaker_profile_'speaker_j'$, "TRAJ_PHON_Z_RATE=")
   Set value... iFile j_rate_traj_phon_z 'v:2'
   Set value... iFile f0_qu02 'rpqu02:2'
   Set value... iFile f0_qu05 'rpqu05:2'
   Set value... iFile f0_qu50 'rpqu50:2'
   Set value... iFile f0_qu95 'rpqu95:2'
   Set value... iFile f0_qu98 'rpqu98:2'
   Set value... iFile sp_qu02 'spqu02:2'
   Set value... iFile sp_qu05 'spqu05:2'
   Set value... iFile sp_qu50 'spqu50:2'
   Set value... iFile sp_qu95 'spqu95:2'
   Set value... iFile sp_qu98 'spqu98:2'
 endif ; nrof_nuclei_analysed
endproc


procedure pitchrange_speakers
; Compute pitch range for each speaker using high and low pitch values of each syllable.
; Should be called after stylization.
   if (speakers < 1)				; speaker are numbered from 1 to N
      call error_msg pitchrange_speakers: Expected >= 1 speaker
   endif
   select nucldatID
   rows = Get number of rows
   if (rows < 1)
      call fatal_error pitchrange_speakers: 0 rows in nucldatID 
   endif

   for speaker_j from 1 to speakers

; For speaker X, compute quantiles of low and high pitch values of each nucleus after stylization. 
; To separate speaker X from others, a temporary table is used and data for other speakers are discarded from it.
; Also discard nuclei with a pitch discontinuity.
      select nucleiID
      k = Get number of points... discontinuity_tier
      select nucldatID
      rows = Get number of rows
      rows2 = rows * 2		; uses 2 pitch values per syllable
      tmptableID = Create Table without column names... pitchvalues rows2 3
      Set column label (index)... 1 pitch_Hz
      Set column label (index)... 2 pitch_ST
      Set column label (index)... 3 starttime
      n = 0			; nrof data points
      for j from 1 to rows
         select nucldatID
         id = Get value... j speaker_id
	 if (id == speaker_j)
           t1_ = Get value... j nucleusstarttime
           t2_ = Get value... j nucleusendtime
	   vlo = Get value... j lopitch
           vhi = Get value... j hipitch
           select nucleiID
	   i_ = Get high index from time... discontinuity_tier t1_
           if (i_ > 0 and i_ <= k)		; time t1_ > time of last discontinuity
	      t_ = Get time of point... discontinuity_tier i_
           else
              t_ = -1 
	   endif
           if (t_ >= t1_-time_step and t_ <= t2_+time_step)	; avoid data at discontinuity
;printline pitchrange: discontinuity, skipped nucleus at 't1_:2'
	   else
;printline pitchrange: nucleus at 't1_:2', lo='vlo:0' hi='vhi:0'
	      select tmptableID
              Set numeric value... n+1 pitch_Hz vlo
              Set numeric value... n+1 pitch_ST hertzToSemitones (vlo) - hertzToSemitones(1)
              Set numeric value... n+1 starttime t1_
              Set numeric value... n+2 pitch_Hz vhi
              Set numeric value... n+2 pitch_ST hertzToSemitones (vhi) - hertzToSemitones(1)
              Set numeric value... n+2 starttime t1_
              n += 2
           endif
	 endif
      endfor
      select tmptableID
      if (n < rows2)		; number of row in table should match number of values
         row = rows2
	 while (row > n)	; remove unused rows at end of table
            Remove row... row
            row -= 1
	 endwhile
      endif
      medianST = Get quantile... pitch_ST 0.5
      ;mean = Get mean... pitch_Hz
      ;meanST = hertzToSemitones (mean) - hertzToSemitones(1)
      select tmptableID
      rows = Get number of rows
      row = rows
      while (row > 0)
         v = Get value... row pitch_ST
         if (abs(v - medianST) > 18)			; discard manifest errors
;t1_ = Get value... row starttime
;printline pitchrange: time='t1_:2', v='v:0' SKIPPED : abs distance from median > 18 ST
            Remove row... row
         endif
         row -= 1
      endwhile
      rows = Get number of rows
      mean = Get mean... pitch_Hz
      median = Get quantile... pitch_Hz 0.5
      bottom = Get quantile... pitch_Hz 0.02
      top    = Get quantile... pitch_Hz 0.98
      stdev  = Get standard deviation... pitch_Hz
      mean_of_ST = Get mean... pitch_ST
      stdev_of_ST = Get standard deviation... pitch_ST
      meanST   = hertzToSemitones (mean) - hertzToSemitones(1)
      medianST = hertzToSemitones (median) - hertzToSemitones(1)
      bottomST = hertzToSemitones (bottom) - hertzToSemitones(1)
      topST    = hertzToSemitones (top) - hertzToSemitones(1)
      select tmptableID
      Remove
      n_ = rows/2			; nrof nuclei used 
      label$ = speaker_label'speaker_j'$
      range = topST - bottomST
      upper_range = 12 * log2 (top/median)
      lower_range = range - upper_range
      speaker_range_'speaker_j'$ = 
      ... "BOTTOM_Hz='bottom:0' BOTTOM_ST='bottomST:1' MEDIAN_Hz='median:0' MEDIAN_ST='medianST:1' " +
      ... "MEAN_Hz='mean:0' MEAN_ST='meanST:1' STDEV_HZ='stdev:2' MEAN_OF_ST='mean_of_ST:2' STDEV_OF_ST='stdev_of_ST:3'" +
      ... "TOP_Hz='top:0' TOP_ST='topST:1' " +
      ... "RANGE_ST='range:1' UPPER_RANGE_ST='upper_range:1' LOWER_RANGE_ST='lower_range:1' NROFNUCL='n_'"

; For speaker X, compute some values using a temporary copy of nucldat, from which data from other speakers will be removed. 
; Computed values include mean and stdev for intrasyllabic and intersyllabic pitch variation,
      min_pause_duration = 0.3
      select nucldatID
      tmptableID = Copy... tmptable
      rows = Get number of rows
      for j from 1 to rows				; Modify value for <intersyllab> when change of speaker 
         t1_ = Get value... j nucleusstarttime
         spkr = Get value... j speaker_id
         if (j > 1)
            prev = Get value... j-1 speaker_id
            if (spkr == speaker_j and spkr <> prev)	; speaker has changed
               Set value... j intersyllab 0
            endif
         endif
      endfor
      j = 1
      while (j <= rows)					; Discard info from other speakers
         spkr = Get value... j speaker_id
         if (spkr <> speaker_j)
            Remove row (index)... j
            rows -= 1
            j -= 1
         endif
         j += 1
      endwhile
      sum_traj_intra = 0	; intrasyllabic trajectory
      sum_traj_inter = 0	; intersyllabic trajectory
      sum_nucldur = 0
      sum_internucldur = 0	; time between nuclei, corrected for pauses
      sum_pausedur = 0		; time of pauses
      nrises = 0
      nfalls = 0
      ngliss = 0
      for j from 1 to rows
         sum_nucldur += Get value... j nucleusdur
         v = Get value... j intersyllab
         v_traj_inter = abs(v)
         v = Get value... j internucleusdur
         if (v < min_pause_duration)
            sum_internucldur += v
            sum_traj_inter += v_traj_inter
         else
            sum_pausedur += v
            Set value... j intersyllab 0		; needed for later
         endif
         sum_traj_intra += Get value... j trajectory
         v = Get value... j intrasyllabup
         dyn = 0
         if (v >= 4)
            nrises += 1
            dyn = 1
         endif
         v = Get value... j intrasyllabdown
         if (v <= -4)
            nfalls += 1
            dyn = 1
         endif
         if (dyn)
            ngliss += 1
         endif
      endfor
      traj_intra_rate = 0
      traj_inter_rate = 0
      traj_phon_rate = 0
      if (sum_nucldur > 0)
         traj_intra_rate = sum_traj_intra/sum_nucldur
      endif
      if (sum_internucldur > 0)
         traj_inter_rate = sum_traj_inter/sum_internucldur
         traj_phon_rate = (sum_traj_inter+sum_traj_intra)/(sum_internucldur+sum_nucldur)
      endif
      mean_intra_up = Get column mean (index)... intrasyllabup 
      stdev_intra_up = Get column stdev (index)... intrasyllabup 
      mean_abs_inter = Get column mean (index)... intersyllab	; meanwhile tweeked
      stdev_abs_inter = Get column stdev (index)... intersyllab 
      select tmptableID
      Remove
      if (ngliss > 0) 
         prises = 100*nrises/rows
         pfalls = 100*nfalls/rows
         pgliss = 100*ngliss/rows
      else
         prises = 0
         pfalls = 0
         pgliss = 0
      endif
      v1 = traj_intra_rate/stdev_of_ST		; time-normalised intrasyllabic trajectory in z-score
      v2 = traj_inter_rate/stdev_of_ST		; time-normalised intersyllabic trajectory in z-score
      v3 = traj_phon_rate/stdev_of_ST		; time-normalised total trajectory in z-score
      ppauses = sum_pausedur/(sum_internucldur+sum_nucldur+sum_pausedur)
      label$ = speaker_label'speaker_j'$
      speaker_profile_'speaker_j'$ = "M_INTRA_UP='mean_intra_up:1' S_INTRA_UP='stdev_intra_up:2' " +
      ... "M_ABS_INTER='mean_abs_inter:1' S_ABS_INTER='stdev_abs_inter:2' " +
      ... "NUCL_DUR='sum_nucldur:2' INTERNUCL_DUR='sum_internucldur:2' PAUSE_DUR='sum_pause:dur:2' PAUSES='ppauses:2' " +
      ... "TRAJ_INTER='sum_traj_inter:2' TRAJ_INTER_RATE='traj_inter_rate:2' TRAJ_PHON_RATE='traj_phon_rate:2'" +
      ... "TRAJ_INTRA='sum_traj_intra:2' TRAJ_INTRA_RATE='traj_intra_rate:2' " +
      ... "TRAJ_INTRA_Z_RATE='v1:3' TRAJ_INTER_Z_RATE='v2:3' TRAJ_PHON_Z_RATE='v3:3' " +
      ... "GLISS='pgliss:1' RISES='prises:1' FALLS='pfalls:1'"

   endfor ; for speaker_j
   call pitchrange_speakers_report
   print 'result$'
   call pitchprofile_speakers_report
   print 'result$'
endproc


procedure pitchrange_speakers_report
   buf$ = ""
   len = 0
   for speaker_j from 1 to speakers
      s$ = speaker_label'speaker_j'$
      len = max (len, length (s$))
   endfor
   len = max (len, length ("Speaker label"))
   leading$ = "     "
   buf$ = "Pitch range of speaker(s):'newline$'"
   call sprint_fs len Speaker label
   buf$ = buf$ + leading$ + result$ + ": Range, Bottom, Mean, Median, Top" + newline$
   for speaker_j from 1 to speakers
      label$ = speaker_label'speaker_j'$
      call sprint_fs len 'label$'
      buf$ = buf$ + leading$ + result$ + ": "
      v = extractNumber (speaker_range_'speaker_j'$, "RANGE_ST=")
      buf$ = buf$ + "'v:1'ST, "
      v = extractNumber (speaker_range_'speaker_j'$, "BOTTOM_Hz=")
      buf$ = buf$ + "'v:0'Hz "
      v = extractNumber (speaker_range_'speaker_j'$, "BOTTOM_ST=")
      buf$ = buf$ + "('v:1'ST), "
      v = extractNumber (speaker_range_'speaker_j'$, "MEAN_Hz=")
      buf$ = buf$ + "'v:0'Hz "
      v = extractNumber (speaker_range_'speaker_j'$, "MEAN_ST=")
      buf$ = buf$ + "('v:1'ST), "
      v = extractNumber (speaker_range_'speaker_j'$, "MEDIAN_Hz=")
      buf$ = buf$ + "'v:0'Hz "
      v = extractNumber (speaker_range_'speaker_j'$, "MEDIAN_ST=")
      buf$ = buf$ + "('v:1'ST), "
      v = extractNumber (speaker_range_'speaker_j'$, "TOP_Hz=")
      buf$ = buf$ + "'v:0'Hz "
      v = extractNumber (speaker_range_'speaker_j'$, "TOP_ST=")
      buf$ = buf$ + "('v:1'ST)"
      buf$ = buf$ + newline$
   endfor ; for speaker_j
   result$ = buf$
endproc


procedure pitchprofile_speakers_report
   buf$ = ""
   len = 0
   for speaker_j from 1 to speakers
      len = max (len, length (speaker_label'speaker_j'$))
   endfor
   len = max (len, length ("Speaker label"))
   leading$ = "     "
   buf$ = "Pitch and duration profile of speaker(s):'newline$'"
   call sprint_fs len Speaker label
   buf$ = buf$ + leading$ + result$ + ": NuclDur, InterNuclDur, TrajIntra, TrajInter, TrajPhon, TrajIntraZ, TrajInterZ, TrajPhonZ, Gliss, Rises, Falls" + newline$
   for speaker_j from 1 to speakers
      label$ = speaker_label'speaker_j'$
      call sprint_fs len 'label$'
      buf$ = buf$ + leading$ + result$ + ": "
      v = extractNumber (speaker_profile_'speaker_j'$, "NUCL_DUR=")
      buf$ = buf$ + "'v:2' s, "
      v = extractNumber (speaker_profile_'speaker_j'$, "INTERNUCL_DUR=")
      buf$ = buf$ + "'v:2' s, "
      v = extractNumber (speaker_profile_'speaker_j'$, "TRAJ_INTRA_RATE=")
      buf$ = buf$ + "'v:1' ST/s, "
      v = extractNumber (speaker_profile_'speaker_j'$, "TRAJ_INTER_RATE=")
      buf$ = buf$ + "'v:1' ST/s, "
      v = extractNumber (speaker_profile_'speaker_j'$, "TRAJ_PHON_RATE=")
      buf$ = buf$ + "'v:1' ST/s, "
      v = extractNumber (speaker_profile_'speaker_j'$, "TRAJ_INTRA_Z_RATE=")
      buf$ = buf$ + "'v:1' sd/s, "
      v = extractNumber (speaker_profile_'speaker_j'$, "TRAJ_INTER_Z_RATE=")
      buf$ = buf$ + "'v:1' sd/s, "
      v = extractNumber (speaker_profile_'speaker_j'$, "TRAJ_PHON_Z_RATE=")
      buf$ = buf$ + "'v:1' sd/s, "
      v = extractNumber (speaker_profile_'speaker_j'$, "GLISS=")
      buf$ = buf$ + "'v:1'%, "
      v = extractNumber (speaker_profile_'speaker_j'$, "RISES=")
      buf$ = buf$ + "'v:1'%, "
      v = extractNumber (speaker_profile_'speaker_j'$, "FALLS=")
      buf$ = buf$ + "'v:1'% "
      buf$ = buf$ + newline$
   endfor ; for speaker_j
   result$ = buf$
endproc


procedure sprint_fs .len .text$
; print string using fixed length, appending blanks if necessary
   .j = .len - length(.text$) 
   if (.j > 0)
     for .k to .j
        .text$ = .text$ + " "
     endfor
   endif
   result$ = .text$
endproc



procedure pitch_to_zscore paramID use_ST
; Convert Pitch object (Hz) to z-score of HZ values or of ST values
; <result1>	mean
; <result2>	stdev
   select paramID
   dataID = To Matrix
   ncols = Get number of columns
   dx = Get column distance
   x1 = Get x of column... 1
   if (use_ST)			; convert to ST
      for col from 1 to ncols
         value = Get value in cell... 1 col
         if (value > 0)		; else unvoiced, pitch absent
	    value = 12 * log2 (value)
         endif
	 Set value... 1 col value
      endfor
   endif
   ; Calculate mean and stdev of voiced points
   mean = 0
   n = 0
   select dataID
   for col from 1 to ncols
      value = Get value in cell... 1 col
      if (value > 0)
         mean += value
         n += 1
      endif
   endfor
   mean = mean/n
   sumdev = 0
   for col from 1 to ncols
      value = Get value in cell... 1 col
      if (value > 0)
         dev = (value - mean)
         sumdev += (dev * dev)
      endif
   endfor
   stdev = sqrt(sumdev/n)
;printline z-score: mean='mean:3' stdev='stdev:3'
   for col from 1 to ncols
      value = Get value in cell... 1 col
      if (value > 0)
         Set value... 1 col (value-mean)/stdev
      endif
   endfor
   result1 = mean 
   result2 = stdev
endproc
