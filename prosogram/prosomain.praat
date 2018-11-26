# prosomain.praat -- include file for prosogram.praat
# Author: Piet Mertens
# Last modification: 2012-03-27

# Modify the following line to match the path of the application on your computer.
path_ghostscript$ = "\Program Files\gs\gs9.05\bin\gswin32c"	  ; typical path on Windows 

# Don't change the following line:
path_ghostscript$ = replace$ (path_ghostscript$, "\Program Files\", "\Progra~1\", 1)	  

boundary_annotation = 0		; automatic detection of prosodic boundaries
stress_annotation = 0		;
needs_loudness = 0		; 1 when loudness is needed for prominence measurement
include_loudness = 0		; 1 when loudness is included in spreadsheet
plot_pauses = 1			;
show_pseudosyllables = 0	; show pseudosyllables in textgrid
show_harmonicity = 0		;
show_prominence = 0		;
single_fname_graphics_output = 0; when true, all graphic files will numbered using the same basename
mindur_pause_anno = 0.2		; min duration for pause in annotation
prefilterHP100 = 0		; Apply HP filtering to avoid problems with low quality audio recordings
prefilterLP = 0			; Apply LP filtering when fricatives are too strong (low quality audio recording)
rhapsodie = 0			; Activate settings for Rhapsodie files
project_frfc = 0		; FRFC project conventions for pauses

;if (boundary_annotation or contour_annotation)
;call logging_start
;include rules.praat
;include prominence.praat
;endif



# Show input speech filename on prosogram : 
   file_stamp = 1
# Show version number : 
   plot_version = 1
# Unit (ST or Hz) used for expressing shown pitch range
   units$ = "Semitones"


procedure main
   if (praatVersion < 5107)
      call fatal_error Requires Praat version 5.1.07 or higher. Please upgrade your Praat version 
   endif

   call process_form
   call fname_parts 'input_files$'
   fname$ = result1$
   basename$ = result2$
   indir$ = result4$
   if (task == task_interactive and nrofFiles > 1)
      printline Interactive mode uses a single speech file, not many.
      nrofFiles = 1
   endif

;if (index_regex (basename$, "^Rhap-"))
;   rhapsodie = 1		; use settings (file encoding, file names, tier names) for Rhapsodie project
if (rhapsodie)
   Text reading preferences... UTF-8
   Text writing preferences... UTF-8
endif

   call initialization_global


for iFile to nrofFiles
   call initialization_per_file
   if (use_filelist)
      select Strings filelist
      fname$ = Get string... iFile
   endif
   call construct_filenames 'fname$'

   if (task == task_interactive)
      call gr_start_demowin
      call gr_printline Processing input file 'fname$'
   else
      call msg 'newline$'Processing input file 'fname$'...
   endif


   call peek_signal
   anal_t2 = signal_finish
   if (task = task_calc_pitch)
      anal_t1 = signal_start
      call calculate_pitch
      select pitchID
      Remove
      pitch_available = 0
   elsif (task = task_calc_loudness)
      call calculate_loudness
      select loudnessID
      Remove
      loudness_available = 0
   else
      if (ending_at > 0)
         anal_t2 = min(ending_at, signal_finish)
      endif
      if (anal_t1 >= signal_finish)
         call fatal_error The start time you supplied ('anal_t1:3') is outside the time range of the sound ('signal_start:3' - 'signal_finish:3')
      endif
      if (anal_t1 >= anal_t2)
         call fatal_error The start time you supplied ('anal_t1:3') is larger than the used end time ('anal_t2:3')
      endif
   endif
   if (task = task_prosogram)
      if (anal_t1 == signal_start and anal_t2 == signal_finish)
         needs_pitchrange = 1	; calculate pitchrange for prosodic profile
      endif
   endif

if (alright)
   call msg Analysis time range: 'anal_t1:3' - 'anal_t2:3' 
   if (need_parameters)
      call msg Calculating/Loading parameters...
      call gr_printline Reading parameter files...
      call read_files
      call gr_printline Calculating parameters...
      call calculate_parameters
   endif
   if (task != task_interactive and signal_available)	; Free memory if possible
      select soundID 
      Remove
      signal_available = 0
   endif

   if (task != task_calc_pitch and task != task_segmentation and task != task_duration)
      call msg Preparing TextGrid plotted in prosograms...
      call prepare_plotted_textgrid 'tiers_to_show$'
   endif

   if (need_stylization or task == task_segmentation)
      if (contour_annotation or needs_pitchrange)
         t1s = signal_start
         t2s = signal_finish
      else
         t1s = anal_t1
         t2s = anal_t2
      endif
      call msg Segmentation into syllabic nuclei. (Method='segmentation_name$', Time range='t1s:3'-'t2s:3')
      call segmentation segm_type
      ; also prepares textgrid "nucleiID" with intermediate data 
   endif


   if (task == task_segmentation)
      select nucleiID
      tmp1 = Extract tier... nucleus_tier
      select nucleiID
      tmp2 = Extract tier... syllable_tier
      select tmp1
      plus tmp2
      tmp3 = Into TextGrid
      call nucleus_tier_postproc tmp3 1 2
      Write to text file... 'autosegfile$'
      select tmp1
      plus tmp2
      plus tmp3
      Remove
      call msg Segmentation written to 'autosegfile$'
   endif
   if (need_stylization)
      if (nrof_nuclei_analysed < 1)
         call error_msg No syllabic nuclei found in speech signal.
         call error_msg If you are using segmentation from annotation tier (phon... or syll...), check tier name and tier content.
         exit
      endif
      call create_table_of_nuclei
   endif

   if (task == task_interactive and reuse_nucl)
    ; stylization cannot be used by boundary_annotation, because procedure stylize computes data in nucldatID
      if (gt_ == glissando and dg_ == diffgt and mints_ == mindur_ts)
         call gr_printline Loading stylization from file 'stylfile$'...
         if (fileReadable (stylfile$))
            stylID = Read from file... 'stylfile$'
            stylization_available = 1
            reuse_styl = 1
         endif
      endif
   endif
   if (need_stylization)
      if (not stylization_available)
       # Create pitch tier object for stylization
         call gr_printline Calculating stylization...
         stylID = Create PitchTier... stylization signal_start signal_finish
         call stylize_nuclei t1s t2s
         ;call time_msg stylize_nuclei ready
      endif
      call speaker_info_get
      if (needs_pitchrange)
         call msg Calculating pitch range...   
         call pitchrange_speakers
      endif
      if (boundary_annotation or stress_annotation)
        if (syllables_available) ; hesitations used in prominence measure
           call msg Detecting hesitations
           call detect_hesitations anal_t1 anal_t2
        endif
        call msg Calculating prominence
        call calculate_prominence_measures anal_t1 anal_t2
      endif

      if (show_pseudosyllables)
        call grid_append_tier nucleiID syllable_tier newgridID
      endif
      if (contour_annotation)
         call msg Tonal annotation...
	 call levels_analysis anal_t1 anal_t2
	 call grid_append_tier nucleiID contour_tier newgridID
         if (not segfile_available)
            select newgridID
            Remove tier... 1	; dummy tier
	 endif
         ; write contour TextGrid
	 select nucleiID
         tmpID = Extract one tier... contour_tier
         Write to text file... 'contourfile$'
         call msg Tonal annotation saved to file...
         Remove
      endif
      if (boundary_annotation)
         call msg Calculating boundaries
	 call boundary_analysis anal_t1 anal_t2 boundary_use_nuclei
         select nucleiID
	 tmpID = Extract one tier... boundary_tier
         Write to text file... 'boundaryfile$'
	 call grid_append_tier nucleiID boundary_tier newgridID
	 call grid_append_tier nucleiID boundary_tier segmentationID
	 call boundary_pass2 anal_t1 anal_t2
	 call grid_append_tier nucleiID boundary2_tier newgridID
         call msg Boundaries ready
      endif
      if (stress_annotation)
	 call stress_analysis anal_t1 anal_t2 pause_use_nuclei
	 call grid_append_tier nucleiID stress_tier newgridID
      endif
      if (need_prosodic_profile)
         call prosodic_profile
      endif
      if (save_intermediate_data)
         if (not reuse_nucl)
            select nucleiID
            Write to text file... 'nuclfile$'
         endif
         if (not reuse_styl)
	    select stylID
	    Write to text file... 'stylfile$'
         endif
      endif
      select stylID	; stylization pitch tier in Hz
      stylSTID = Copy... styl_ST
      call convert_Hz_ST stylSTID

    # Initialization for plotting results of current input file
      if (auto_pitchrange)
         ; GLOBAL automatic pitch range selection for entire corpus to be analysed
         ; call autorange stylSTID nucleiID anal_t1 anal_t2 1
         call speaker_autorange anal_t1 anal_t2
         ySTmax = ymax
         ySTmin = ymin
      endif
   else ; no stylization needed
       if (pitch_available)
	  select pitchID
          y_ = Get mean... 0 0 semitones re 1 Hz
          ySTmin = y_ - 12
          ySTmax = y_ + 12
       endif
   endif ; need_stylization


# Draw all prosograms for current input file
   if (draw_prosograms)
      if (task == task_interactive)
         call gr_start_demowin
         call gr_run_demowin anal_t1 anal_t2 timeincr ySTmin ySTmax
         call cleanup_current_file
         call cleanup_global
         exit
      else
	 call gr_start_picturewin
         if (nrof_pages == 0)
            # grid takes part of plotting area, so adjust lower Y-value
             ySTbottom = ySTmin - nrofplottedtiers*(ySTmax-ySTmin)/4
            call gr_first_viewport_of_page
            nrof_pages = 1
         endif
         call gr_write_all_prosograms anal_t1 anal_t2 timeincr
      endif
   endif ; draw_prosograms
   if (task == task_annotation)
      call gr_start_picturewin
      if (nrof_pages == 0)
         call gr_first_viewport_of_page
         nrof_pages = 1
         call gr_write_all_annotation anal_t1 anal_t2 timeincr
      endif
   endif
   if (save_intermediate_data)		; must follow plotting because save_spreadsheet removes columns
         if (need_prosodic_profile)
	    call save_spreadsheet
         endif
   endif

    # Delete temporary files for current input file
	call cleanup_current_file
endif ; alright
endfor			; loop for next file

if (alright)
   # Write last output file if necessary
      if (task != task_interactive and draw_prosograms)
         if (nrof_plots > 1)
            call gr_write_prosogram
         endif
      endif
endif ; alright
    call cleanup_global
    call msg Ready
endproc


procedure process_form
; flags
   needs_loudness = 0
   needs_intbp = 0		; needs intensity of BP filtered signal 
   needs_segm = 1		; needs segmentation textgrid
   needs_phon_tier = 0		; needs phone tier
   needs_syll_tier = 0		; needs syllable tier
   segfile_available = 0	; segmentation file
   contour_annotation = 0	; automatic annotation of pitch movements and pitch levels

; types of segmentation
   segm_vnucl = 1
   segm_extern = 2
   segm_aloudness = 3
   segm_anucl = 4
   segm_asyll = 5
   segm_msyllvow = 6
   segm_msyllpeak = 7
   segm_mrime = 8		; syllable rime using phoneme and syllable annotation
   segm_voiced = 9		; voiced portions
   if (index (segmentation_method$, "in vowels"))
      segm_type = segm_vnucl
      segmentation_name$ = "vow-nucl"
      needs_phon_tier = 1
   elsif (index (segmentation_method$, "external"))
      segm_type = segm_extern
      segmentation_name$ = "extern"
   elsif (index (segmentation_method$, "loudness"))		; automatic, loudness peaks
      segm_type = segm_aloudness
      segmentation_name$ = "loudness"
      needs_segm = 0
   elsif (index (segmentation_method$, "BP-filtered"))	; automatic, peaks in bandpass filters speech
      segm_type = segm_anucl
      segmentation_name$ = "int-BP"
      needs_intbp = 1
      needs_segm = 0
   elsif (index (segmentation_method$, "Automatic: acoustic syllables"))
      segm_type = segm_asyll
      segmentation_name$ = "asyll"
      needs_intbp = 1
      needs_segm = 0
   elsif (index (segmentation_method$, "in rime"))
      segm_type = segm_mrime
      segmentation_name$ = "rime"
      needs_phon_tier = 1
      needs_syll_tier = 1
   elsif (index_regex (segmentation_method$, "in syllables.*and vowels"))
      segm_type = segm_msyllvow
      segmentation_name$ = "syll+vow"
      needs_phon_tier = 1
      needs_syll_tier = 1
   elsif (index_regex (segmentation_method$, "in syllables.*and local peak"))
      segm_type = segm_msyllpeak
      segmentation_name$ = "syll"
      needs_syll_tier = 1
   elsif (index (segmentation_method$, "Automatic: voiced portions"))
      segm_type = segm_voiced
      segmentation_name$ = "voiced"
   else
      segmentation_name$ = "unknown"
      call fatal_error Unknown segmentation type: 'segmentation_method$'
   endif

; types of tasks
   task_calc_pitch = 1
   task_pitch_plot = 2
   task_segmentation = 3
   task_prosogram = 4
   task_interactive = 5
   task_annotation = 6
   task_profile = 7
   task_boundaries = 8
   task_contours = 9
   task_calc_loudness = 10
   task_duration = 11
   if (index (task$, "Recalculate pitch") > 0)
      task = task_calc_pitch
      needs_segm = 0
   elsif (index (task$, "Recalculate loudness") > 0)
      needs_loudness = 1
      task = task_calc_loudness
      needs_segm = 0
   elsif (index (task$, "Prosogram") > 0)
      task = task_prosogram
   elsif (index (task$, "Prosodic profile only") > 0)
      task = task_profile
   elsif (index (task$, "Plot pitch") > 0)
      task = task_pitch_plot
      needs_segm = 0
   elsif (index (task$, "automatic segmentation") > 0)
      task = task_segmentation
      segm_type = segm_asyll
      needs_intbp = 1
      needs_segm = 0
   elsif (index (task$, "Interactive") > 0)
      task = task_interactive
   elsif (index (task$, "Draw annotation"))
      task = task_annotation
   elsif (index (task$, "boundary"))
      task = task_boundaries
   elsif (index (task$, "contour"))
      task = task_contours
      contour_annotation = 1
   elsif (index (task$, "Duration"))
      task = task_duration
   else
      call fatal_error Invalid task
   endif

; time_step (frame rate) used for calculation of intensity and pitch
   time_step = 'frame_period$'
   anal_t1 = left_Time_range
   ending_at = right_Time_range
; View
   s$ = left$ (view$, index(view$, ":") -1)
   view = 's$'
   # Draw pitch target values (in ST) in prosogram
   draw_pitch_target_values = 0
   rich = 0
   if (index (view$, "rich"))
      rich = 1
   endif
   if (index (view$, "pitch targets"))
      draw_pitch_target_values = 1
   endif
   show_pitchrange = 0
   if (index (view$, "pitch range"))
      show_pitchrange = 1
   endif
; Thresholds
   j = index_regex (thresholds$, "/T")
   s$ = mid$ (thresholds$, 3, j-3)		; s$ = glissando threshold(s)
   if (index (thresholds$, "adaptive"))		; adaptive glissando threshold (lower before pause)
      adaptive_glissando = 1
      s2$ = left$ (s$, 4)
      glissando_low = 's2$'
      s2$ = mid$ (s$, 6, 4)
      glissando = 's2$'
   else						; fixe glissando threshold
      adaptive_glissando = 0
      glissando = 's$'
      glissando_low = glissando
   endif
   diffgt = extractNumber (thresholds$, "DG=")
   mindur_ts = 0.035			; Minimum duration for a tonal segment (default)
   j = index (thresholds$, "dmin")
   if (j > 0)
	s$ = mid$ (thresholds$, j+5, length (thresholds$) -(j+4))
	mindur_ts = 's$'
   endif
   output_mode$ = "Fill page with strips"
   outputmode$ = left$ (output_mode$, index(output_mode$, " ") -1)
   volatile = 0				; by default, process full signal and store results
   if (index (parameter_calculation$, "Partial") > 0)
      volatile = 1
   endif

   minimum_pitch = left_F0_detection_range
   maximum_pitch = right_F0_detection_range
   if (left_Pitch_range == 0)
      auto_pitchrange = 1		; automatic pitch range adjustment
   else
      auto_pitchrange = 0		; manual pitch range adjustment
      if (right_Pitch_range <= left_Pitch_range or left_Pitch_range <= 0)
         call fatal_error "Invalid values for pitch range"
      endif
   endif
   ySTmin = left_Pitch_range
   ySTmax = right_Pitch_range

   if (minimum_pitch < 40 or maximum_pitch > 800)
      call fatal_error "Invalid F0 range: expected to be within 40 - 800 Hz range"
   endif
   if (minimum_pitch >= maximum_pitch)
      call fatal_error "Invalid F0 range: lower limit > higher limit"
   endif
   timeincr = time_interval_per_strip	; time increment for plot

   draw_prosograms = 1
   need_stylization = 1
   need_parameters = 1
   needs_pitchrange = 0
   if (show_pitchrange)
      needs_pitchrange = 1
   endif
   need_prosodic_profile = 0
   show_vuv = 1
   show_intensity = 1
   show_intbp = 1
   show_lengthening = 0		; don't plot lengthening
   if (task == task_calc_pitch or task == task_calc_loudness)
      need_parameters = 0
      volatile = 0
      need_stylization = 0
      draw_prosograms = 0
   elsif (task == task_profile)
      need_prosodic_profile = 1
      draw_prosograms = 0
      needs_pitchrange = 1
   elsif (task == task_pitch_plot)
      show_vuv = 0
      show_intensity = 0
      show_intbp = 0
      need_stylization = 0
      segmentation_name$ = ""
      plot_pauses = 0
   elsif (task == task_interactive)
      rich = 1
      need_prosodic_profile = 0
   elsif (task == task_annotation)
      draw_prosograms = 0
      need_parameters = 0
      need_stylization = 0
   elsif (task == task_prosogram)
      need_prosodic_profile = 1
   elsif (task == task_segmentation)
      draw_prosograms = 0
      need_stylization = 0
   elsif (task == task_boundaries or boundary_annotation)
      boundary_annotation = 1
      show_prominence = 0		; plot prominence measures
      show_lengthening = 1		; plot lengthening
      if (project_frfc)
         boundary_use_nuclei = 0	; 0= use pauses from annotation. 1= use gaps between nuclei 
      else
         boundary_use_nuclei = 1	; 0= use pauses from annotation. 1= use gaps between nuclei 
      endif 
      boundary_annotation_verbose = 1
      save_intermediate_data = 1
      need_prosodic_profile = 0
      if (not (segm_type == segm_msyllvow or segm_type == segm_mrime or segm_type == segm_msyllpeak))
         call error_msg Boundary annotation requires Syllabic segmentation method 
         segm_type = segm_msyllvow
      endif
   elsif (task == task_contours or contour_annotation)
      ; show_prominence = 0		; plot prominence measures 
      needs_pitchrange = 1
   endif
   if (stress_annotation)
      show_prominence = 1		; plot prominence measures 
      pause_use_nuclei = 1		; 1= use gaps between nuclei; 0= use pauses from annotation
   endif

   if (draw_prosograms and (index (output_format$,"EMF")) and not windows)
      call error_msg Windows Metafiles (EMF) are supported on Windows systems only
   endif

;   if (show_pseudosyllables)
;      need_prosodic_profile = 0
;   endif
   s$ = input_files$
   s$ = replace$ (s$, " ", "", 0)
   if (length(s$) < 1)
      input_files$ = chooseReadFile$ ("Select file")
   endif
   if (index (input_files$, "*"))		; wildcard found
      use_filelist = 1
      Create Strings as file list... filelist 'input_files$'
      nrofFiles = Get number of strings
   else
      use_filelist = 0
      nrofFiles = 0
      if (fileReadable (input_files$))    
         nrofFiles = 1
      endif
   endif
   if (nrofFiles == 0)
      call fatal_error No input files found for <'input_files$'>
   endif
endproc


procedure initialization_global
    # diffST = difference in ST between ST-scale relative to 100Hz and that rel to 1Hz
	diffST = 12 * log2(100/1)
    if (units$ = "Semitones")
	yHzmin = semitonesToHertz(ySTmin-diffST)
	yHzmax = semitonesToHertz(ySTmax-diffST)
    else
	ySTmin = hertzToSemitones(yHzmin) - hertzToSemitones(1)
	ySTmax = hertzToSemitones(yHzmax) - hertzToSemitones(1)
    endif

; for graphics
    call gr_init
; for drawing
    file_ctr = 1	; counter for EPS/EMF filename
    nrof_pages = 0
; for globalsheet
    call create_table_global_report
endproc


procedure initialization_per_file
   signal_available = 0		; speech signal loaded
   intensity_available = 0
   pitch_available = 0
   vuv_available = 0
   harmonicity_available = 0
   intbp_available = 0
   inthp_available = 0
   nucldat_available = 0
   loudness_available = 0
   segmentation_available = 0
   stylization_available = 0
   reuse_nucl = 0
   reuse_styl = 0
   phones_available = 0		; 1 if phon tier is found
   syllables_available = 0	; 1 if syll tier is found
   creak_available = 0		; creak textgrid/tier found and read
   speaker_available = 0	; speaker textgrid/tier found and read
   newgrid_available = 0
   alright = 1			; assume all needed files will be found
endproc


procedure construct_filenames fname$
   if (rindex (fname$,".") == 0)
      call fatal_error Invalid filename for input file. Should include filename extension.
   endif
   call fname_parts 'fname$'
   fext$        = replace_regex$ (result3$, "(.)", "\L\1", 0)	; to lowercase
   if (index(":wav:aiff:aifc:nist:flac:", ":'fext$':") == 0)
      printline FileExtension=<'fext$'>
      call fatal_error Input file should be an audio file supported by Praat Open LongSound, with extension .wav, .aiff, .aifc, .nist, or .flac
   endif
   basename$    = result2$
   prefix$	= indir$ + basename$
   signalfile$	= prefix$ + "." + fext$
   pitchfile$	= prefix$ + ".Pitch"
   intensityfile$ = prefix$ + ".Intensity"
   harmonicityfile$ = prefix$ + ".Harmonicity"
   segfile$	= prefix$ + ".TextGrid"			; TextGrid with already available segmentation
   if (rhapsodie)
      ; segfile$ = indir$ + replace_regex$ (basename$, "^(Rhap-)(.*)", "\2", 1) + "-PRO.TextGrid"
      segfile$ = prefix$ + "-Pro.TextGrid"
      if (not fileReadable (segfile$))
         alright = 0
         call error_msg Could not find annotation file <'segfile$'> 
      endif
   endif
   autosegfile$	= prefix$ + "_auto.TextGrid"		; automatic segmentation output
   nuclfile$	= prefix$ + "_nucl.TextGrid"		; nuclfile contains automatic segmentation etc.
   creakfile$	= prefix$ + "_creak.TextGrid"
   speakerfile$	= prefix$ + "_speaker.TextGrid"
   contourfile$	= prefix$ + "_contour.TextGrid"
   boundaryfile$ = prefix$ + "_boundary.TextGrid"
   intbpfile$	= prefix$ + "_BP.Intensity"
   inthpfile$	= prefix$ + "_HP.Intensity"
   loudnessfile$ = prefix$ + "_loud.Intensity"
   # The following files are created in the data directory and deleted on exit unless "Save intermediate data"
   stylfile$	= prefix$ + "_styl.PitchTier"
   statsfile$	= prefix$ + "_profile.txt"
   sheetfile$	= prefix$ + "_spreadsheet.txt"
   globalfile$	= indir$  + "globalsheet.txt"

   output_fname$ = output_filename$	; local copy of specification given on script form
   if (length (indir$))
      output_fname$ = replace$ (output_fname$, "<input_directory>", indir$, 1)
   else
      output_fname$ = replace$ (output_fname$, "<input_directory>/", "", 1)
   endif
   output_fname$ = replace$ (output_fname$, "<basename>", basename$, 1)
   output_fname$ = replace$ (output_fname$, "//", "/", 1)
   if (single_fname_graphics_output)
      output_filename$ = output_fname$	; keep name for all graphics output files
   else
      file_ctr = 1	; counter for EPS/EMF filename
      nrof_pages = 0
   endif
endproc


procedure prepare_plotted_textgrid ltiers$
# Prepare textgrid for plot using tiers  
   nrofplottedtiers = 0
   segfile_available = 0
   if (fileReadable (segfile$))
      segfile_available = 1
   endif
   if (segfile_available == 0 and needs_segm)
      call fatal_error Cannot open TextGrid file with segmentation
   endif
   if (segfile_available == 0 and contour_annotation)
      newgridID = Create TextGrid... signal_start signal_finish dummy 
      newgrid_available = 1
   endif
   if (segfile_available)
      tiers = 0
      segmentationID = Read from file... 'segfile$'
      call msg Reading annotation file "'segfile$'"
      nrofTiers = Get number of tiers
      call tier_number_by_name segmentationID "^speaker$"
      speaker_tier_in = result
      repeat
         call next_field 'ltiers$'
         if (result > 0)		; next field found
            field$ = result2$
            if (left$ (field$, 1) = "*")
               field$ = right$ (field$, length(field$) - 1)
               convert = 1
            else
               convert = 0
            endif
            call is_number 'field$'
            if (result == 0)		; next field is not a number
               call tier_number_by_name segmentationID field$
               tier_in = result
               if (result == 0)		; tier name not found
                  call error_msg No tier named "'field$'" found in input textgrid. Change content of field "Tiers to show".
                  call error_msg This tier will be skipped in prosogram.
               endif
            else			; field is a number
               tier_in = 'field$'
               if (tier_in > nrofTiers) 
                  call error_msg Tier 'tier_in' not found. Input textgrid has only 'nrofTiers' tiers. Change content of field "Tiers to show".
                  call error_msg This tier will be skipped in prosogram.
                  tier_in = 0
               endif
            endif
            if (tier_in > 0)		; valied tier to add
               if (tiers == 0)		; this is first tier to add to plotted grid
                  select segmentationID
                  ok = Is interval tier... tier_in
                  tmpID = Extract tier... tier_in
                  newgridID = Into TextGrid
                  newgrid_available = 1
	          select tmpID
	          Remove
               else
                  call grid_append_tier segmentationID tier_in newgridID
               endif
               tiers += 1
               if (convert)
                  call convert_sampa_ipa newgridID tiers
	       endif
	    endif
         endif
         ltiers$ = result3$
      until (result == 0)
      nrofplottedtiers = tiers
   endif ; segfile_available
   if (contour_annotation or boundary_annotation or show_pseudosyllables)
      nrofplottedtiers += 1		; results will appear in extra tier 
   endif
   if (stress_annotation)
      nrofplottedtiers += 1		; results will appear in extra tier 
   endif
endproc


procedure peek_signal
   Open long sound file... 'signalfile$'
   signal_start = Get starting time
   signal_finish = Get finishing time
   Remove
endproc


procedure read_signal
   soundID = Read from file... 'signalfile$'
   fullsoundID = soundID
   signal_start = Get starting time
   signal_finish = Get finishing time
   signal_available = 1
endproc


procedure read_files
   if (fileReadable (pitchfile$))
      pitchID = Read from file... 'pitchfile$'
      t = Get end time
      if (t + 5*time_step < signal_finish)
         call msg Pitch file end time ('t' s) < speech signal end time ('signal_finish' s)
      endif
      pitch_available = 1
   endif
   if (show_harmonicity)
      if (fileReadable (harmonicityfile$))
         harmonicityID = Read from file... 'harmonicityfile$'
         harmonicity_available = 1
      endif
   endif
   if (needs_loudness or include_loudness)
      if (fileReadable (loudnessfile$))
         loudnessID = Read from file... 'loudnessfile$'
         loudness_available = 1
      endif
   endif
   if (needs_intbp)
      if (fileReadable (intbpfile$))
         intbpID = Read from file... 'intbpfile$'
         intbp_available = 1
      endif
   endif
endproc


procedure calculate_pitch
; Standard settings, see FAQ Pitch Analysis
   voicing_threshold = 0.45
   silence_threshold = 0.03
   octave_jump_cost = 0.35
   tstep = 0			; automatic, i.e. 0.75/pitch_floor, for 60Hz, this is 0.0125 s
; Modified settings
   ;voicing_threshold = 0.2	; setting for v2.8
   ;voicing_threshold = 0.35	; setting for v2.7
   ;octave_jump_cost = 0.2
   tstep = time_step		; typically 0.01 or 0.005 s

   call msg Calculating pitch... 'newline$'Time step='tstep:2', Pitch floor='minimum_pitch' Hz, Voicing threshold='voicing_threshold:2', Pitch ceiling='maximum_pitch' Hz
   if (not signal_available)
      call read_signal
   endif
   select soundID
   ; pitchID = To Pitch... time_step minimum_pitch maximum_pitch
   pitchID = To Pitch (ac)...  tstep minimum_pitch 15 no silence_threshold voicing_threshold 0.01 octave_jump_cost 0.14 maximum_pitch
   if (not volatile)
      Write to binary file... 'pitchfile$'
   endif
   pitch_available = 1
endproc


procedure calculate_loudness
   if (not signal_available)
      call read_signal
   endif
   execute loudness.praat 'soundID' 'signal_start' 'signal_finish' 'time_step'
   loudnessID = selected ("Intensity", -1)
   if (not volatile)
      Write to binary file... 'loudnessfile$'
   endif
   loudness_available = 1
endproc


procedure calculate_parameters
    fc_low = 300
    fc_high = 3500
    if (not signal_available)
      call read_signal
      signal_available = 1
    endif
    if (volatile)
    # Calculate parameters on the fly only for interval to stylize
	select soundID
	tmpsoundID = Extract part... anal_t1 anal_t2 Rectangular 1.0 yes
	# Redefine soundID !!
	soundID = tmpsoundID
	select soundID
	intensityID = To Intensity... 100 time_step
	intensityID = selected ("Intensity", -1)		; keep this line !!
	intensity_available = 1
	call calculate_pitch
      if (needs_loudness and not loudness_available)
	execute loudness.praat 'soundID' 'anal_t1' 'anal_t2' 'time_step'
	loudnessID = selected ("Intensity", -1)
	loudness_available = 1
      endif
      if (needs_intbp and not intbp_available)
	select soundID
	Filter (pass Hann band)... fc_low fc_high 100
	tmpfsID = selected ("Sound", -1)
	intbpID = To Intensity... 100 time_step
	intbpID = selected ("Intensity", -1)		; keep this line !!
	select tmpfsID
	Remove
	intbp_available = 1
      endif
    else ; (volatile == 0)
      if (not intensity_available)

    if (rhapsodie and basename$ = "Rhap-D0008")
       prefilterHP100 = 1
    endif

    if (prefilterHP100)
    ; Apply HP filtering to avoid problems with low quality recordings by filtering low frequency band
        printline Preprocessing (high-pass filtering) speech signal... 'basename$'
	select soundID
        fc_low = 100
	tmpID = Filter (pass Hann band)... fc_low 0 100
	select soundID
	Remove
	soundID = tmpID
    endif
    if (prefilterLP)
    ; Apply LP filtering when fricatives are very intense
        printline Preprocessing (low-pass filtering) speech signal... 'basename$'
	select soundID
	fc = 2500
	tmpID = Filter (pass Hann band)... 0 fc 100
	select soundID
	Remove
	soundID = tmpID
    endif

        select soundID
        tmpID = To Intensity... 100 time_step
	intensityID = selected ("Intensity", -1)		; keep this line !!
	intensity_available = 1
      endif
      if (not pitch_available)
        call calculate_pitch
      endif
      if (show_harmonicity and not harmonicity_available)
	select soundID
	silence_threshold = 0.1
	nrofperiods = 1.0
	harmonicityID = To Harmonicity (cc)... time_step minimum_pitch silence_threshold nrofperiods
        harmonicity_available = 1
      endif
      if (needs_loudness and not loudness_available)
	execute loudness.praat 'soundID' 'signal_start' 'signal_finish' 'time_step'
	loudnessID = selected ("Intensity", -1)
	Write to short text file... 'loudnessfile$'
	loudness_available = 1
      endif
      if (needs_intbp and not intbp_available)
	select soundID
	Filter (pass Hann band)... fc_low fc_high 100
	tmpfsID = selected ("Sound", -1)
	intbpID = To Intensity... 100 time_step
	intbpID = selected ("Intensity", -1)		; keep this line !!
	Write to short text file... 'intbpfile$'
	select tmpfsID
	Remove
	intbp_available = 1
      endif
    endif ; # volatile
    # Calculate V/UV decision and store in TextGrid
      select pitchID
      pointprocID = To PointProcess
      vuvgridID = To TextGrid (vuv)... 0.02 0.01
      Rename... vuv
      select pointprocID
      Remove
      vuv_available = 1
endproc


procedure segmentation method
   if (method == segm_vnucl)		; vowel nuclei
      segmentation_name$ = "vow-nucl"
   elsif (method == segm_extern)
      segmentation_name$ = "extern"
   elsif (method == segm_aloudness)	; automatic, loudness peaks
      segmentation_name$ = "loudness"
   elsif (method == segm_anucl)		; automatic, peaks in bandpass filters speech
      segmentation_name$ = "int-BP"
   elsif (method == segm_msyllvow)	; syllabic nuclei
      segmentation_name$ = "syll+vow"
   elsif (method == segm_msyllpeak)	; syllabic nuclei
      segmentation_name$ = "syll"
   elsif (method == segm_mrime)		; syllable rime
      segmentation_name$ = "rime"
   elsif (method == segm_asyll)		; pseudo-syllables
      segmentation_name$ = "asyll"
   elsif (method == segm_voiced)	; voiced portions
      segmentation_name$ = "voiced"
   else
      segmentation_name$ = "unknown"
   endif

   if (task == task_interactive)
      if (fileReadable (nuclfile$))
         tmpID = Read from file... 'nuclfile$'
         call tier_number_by_name tmpID "^settings$"
         if (result > 0)
   	    settings_tier = result
   	    s$ = Get label of interval... settings_tier 1
   	    method_$ = extractWord$ (s$, "SEG=")
   	    t1_ = extractNumber (s$, "t1=")
   	    t2_ = extractNumber (s$, "t2=")
   	    gt_ = extractNumber (s$, "GT=")
   	    dg_ = extractNumber (s$, "DG=")
   	    mints_ = extractNumber (s$, "MINTS=")
;printline settings found T1='t1_:3' T2='t2_:3' found method_='method_$'
   	    if (anal_t1 >= t1_ and anal_t2 <= t2_)
;printline times match: anal_t1='anal_t1:3' anal_t2='anal_t2:3'
   	     if (method_$ = segmentation_name$)
;printline names match: method_='method_$' segmentation_name='segmentation_name$'
                  call tier_number_by_name tmpID "^phones?$"
                  phone_tier = result
;printline segmentation: nucl_file, phone_tier='phone_tier'
	       ;if (boundary_annotation and result == 0)
                  ;call msg Could not find tier named "phone" or "phones"
	       ;endif
               if (result > 0)
                  call tier_number_by_name tmpID "^syll$"
                  syllable_tier = result
               endif
               if (result > 0)
                  call tier_number_by_name tmpID "^nucleus$"
                  nucleus_tier = result
               endif
               if (result > 0)
                  call tier_number_by_name tmpID "^vuv$"
                  vuv_tier = result
               endif
               if (result > 0)
                  call tier_number_by_name tmpID "^discont$"
                  discontinuity_tier = result
               endif
               if (result > 0)
                  call tier_number_by_name tmpID "^safe$"
                  safe_tier = result
               endif
               if (result > 0)
                  call tier_number_by_name tmpID "^contour$"
                  contour_tier = result
               endif
               if (result > 0 and boundary_annotation)
                  call tier_number_by_name tmpID "^pointer$"
                  pointer_tier = result
               endif
               if (result > 0)
                  reuse_nucl = 1
                  segmentation_available = 1
                  nucleiID = tmpID
                  nrof_nuclei_analysed = Count labels... safe_tier a
                  if (task == task_interactive)
                      call gr_printline Loaded segmentation from file 'nuclfile$'
                  else
                      printline Loaded segmentation from file 'nuclfile$'
                  endif
                  if (boundary_annotation)
   	             call tier_number_by_name tmpID "^boundary-auto$"
                     if (result > 0)
                        boundary_tier = result
                        call tier_clear nucleiID boundary_tier
                     else                  
                        n = Get number of tiers
                        boundary_tier = n+1
                        Insert point tier... boundary_tier boundary-auto
                     endif                  
   	             call tier_number_by_name segmentationID "^syll$"
                     syll_tier_in = result
                     call copy_tier segmentationID syll_tier_in nucleiID syllable_tier 
		  endif                  
	       endif
             endif ; if name = 
   	    endif ; if anal_t1 ..  
         endif ; settings found
         if (not segmentation_available) ; textgrid read but not used
            select tmpID
            Remove
         endif
      endif ; file readable
;printline segmentation_available='segmentation_available' reuse_nucl nr='nrof_nuclei_analysed'
   endif ; task_interactive

   if not segmentation_available
      call gr_printline Calculating segmentation...
# Make segmentation into nuclei depending upon segmentation method
    # tiers in annotation textgrid file
	phone_tier_in = 1	; default location
    # create TextGrid nucleiID with 11 tiers
	phone_tier = 1
	dip_tier = 2
	nucleus_tier = 3
	syllable_tier = 4
	vuv_tier = 5
	discontinuity_tier = 6
	safe_tier = 7
	pointer_tier = 8 
        settings_tier = 9
        speaker_tier = 10
        creak_tier = 11
	boundary_tier = 0	; may be added later for boundary_annotation
	contour_tier = 0	; may be added later for contour_annotation
	stress_tier = 0		; may be added later for stress_annotation
	n = 11
        tiers$ = "phone dip nucleus syll vuv discont safe pointer settings speaker creak"
	point_tiers$ = "dip discont"
	if (boundary_annotation)
           tiers$ = tiers$ + " boundary-auto"
	   point_tiers$ = point_tiers$ + " boundary-auto"
	   n += 1
	   boundary_tier = n
        endif
	if (contour_annotation)
           tiers$ = tiers$ + " contour"
	   n += 1
	   contour_tier = n
        endif
        if (stress_annotation)
           tiers$ = tiers$ + " stress"
           n += 1
           stress_tier = n
        endif
        nucleiID = Create TextGrid... signal_start signal_finish "'tiers$'" 'point_tiers$'
        Rename... nucl
    # copy VUV decision from vuvgrid to nuclei grid
        call copy_tier vuvgridID 1 nucleiID vuv_tier


   if (segfile_available)
      call tier_number_by_name segmentationID "^phon"
      if (result)
         phone_tier_in = result
         call msg Reading phonetic alignment from tier named "'result2$'"
         phones_available = 1
      else
         phone_tier_in = 1	; assume tier 1 contains phonetic alignment
      endif
      call copy_tier segmentationID phone_tier_in nucleiID phone_tier
      call tier_number_by_name segmentationID "^syll"
      if (result and segm_type <> segm_asyll)
      ; In segm_asyll, the syllable tier is used for pseudo-syllables and should be used for true syllables.
         syll_tier_in = result
         call msg Reading syllable alignment from tier named "'result2$'"
         call copy_tier segmentationID syll_tier_in nucleiID syllable_tier 
         syllables_available = 1
      endif
      call tier_number_by_name segmentationID "^speaker$"
      if (rhapsodie)
         call tier_number_by_name segmentationID "^locuteur$"
      endif
      if (result)
         speaker_tier_in = result
         call msg Reading speaker information from tier named "'result2$'"
         call copy_tier segmentationID speaker_tier_in nucleiID speaker_tier
         speaker_available = 1	; speaker tier available
      else			; input segmentation textgrid does not contain speaker tier 
         select nucleiID
         Set interval text... speaker_tier 1 ANON
      endif
      call tier_number_by_name segmentationID "^[Cc]reaky?$"
      if (result)
         call msg Using creak information from tier named "'result2$'" of "'segfile$'"
         call copy_tier segmentationID result nucleiID creak_tier
         creak_available = 1
      endif
      word_tier_in = 0
      call tier_number_by_name segmentationID "^word$"
      if (result)
         word_tier_in = result
      endif
   endif
   if (not speaker_available)
      if (fileReadable (speakerfile$))
         call msg Reading speaker information from 'speakerfile$' 
         tmpID = Read from file... 'speakerfile$'
         call tier_number_by_name tmpID "^speaker$"
         if (result > 0)
            call copy_tier tmpID result nucleiID speaker_tier
            speaker_available = 1
         else
            call msg No speaker tier found in 'speakerfile$' 
         endif
         select tmpID
         Remove
      endif
   endif
   if (not creak_available)
      if (fileReadable (creakfile$))
         call msg Reading 'creakfile$' 
         tmpID = Read from file... 'creakfile$'
         call tier_number_by_name tmpID "^[Cc]reaky?$"
         if (result > 0)
            call msg Reading creak information from tier 'result' of "'creakfile$'"
            call copy_tier tmpID result nucleiID creak_tier
            creak_available = 1
         endif
         select tmpID
         Remove
      endif
   endif

   if (needs_phon_tier and not phones_available)
      call fatal_error Cannot find phoneme tier (named "phon...") in annotation TextGrid
   endif
   if (needs_phon_tier and not syllables_available)
      call fatal_error Cannot find syllable tier (named "syll...") in annotation TextGrid
   endif

   call msg Calculating actual segmentation...
   if (segm_type != segm_extern)
      call make_segmentation segm_type t1s t2s nucleiID
   else
      select segmentationID
      call tier_number_by_name segmentationID "^segm"
      if (result = 0)
	   call fatal_error Cannot find segmentation tier (named "segm...") in segmentation TextGrid
      endif
      tier_in = result
      call copy_tier segmentationID tier_in nucleiID nucleus_tier
      select nucleiID
      n_ = Get number of intervals... nucleus_tier
      for j from 1 to n_
         label$ = Get label of interval... nucleus_tier j
         call is_vowel 'label$'
         if (is_vowel)
            Set interval text... nucleus_tier j a
         endif
      endfor
   endif

   call safe_nuclei t1s t2s
   nrof_nuclei_analysed = result

   s$ = "File='basename$' SEG='segmentation_name$' t1='t1s' t2='t2s' GT='glissando' DG='diffgt' MINTS='mindur_ts' MINPAUSE='pause_mindur'"
   select nucleiID
   Set interval text... settings_tier 1 's$'

  # prepare for contour analysis
    if (contour_annotation)
       select nucleiID
       Remove tier... contour_tier		; is empty tier when object is created
       if (segm_type == segm_msyllvow or segm_type == segm_msyllpeak or segm_type == segm_mrime)	
          ; use syllable boundaries for contour labels
          Duplicate tier... syllable_tier contour_tier contour
       elsif (segm_type == segm_vnucl and segfile_available and syllables_available)
          Duplicate tier... syllable_tier contour_tier contour
       else
          Duplicate tier... nucleus_tier contour_tier contour
       endif
       call tier_clear_text nucleiID contour_tier
    endif ; contour_annotation
    if (stress_annotation)
       if (segm_type == segm_msyllvow or segm_type == segm_msyllpeak or segm_type == segm_mrime)
          call tier_replace nucleiID syllable_tier nucleiID stress_tier
       elsif (segm_type == segm_vnucl and segfile_available and syllables_available)
          call tier_replace nucleiID syllable_tier nucleiID stress_tier
       else
          call tier_replace nucleiID nucleus_tier nucleiID stress_tier
       endif
       call tier_clear_text nucleiID stress_tier
    endif ; contour_annotation
   endif ; not segmentation available

endproc


# Clip a PitchTier by replacing data points outside clip range
# by values 1 ST outside range
procedure clipPitchTier objectID ymin ymax xmin xmax
   select objectID
   firsti = Get low index from time... xmin
   if (firsti = 0)
      firsti = 1
   endif
   lasti = Get nearest index from time... xmax
   n = Get number of points
   for i from firsti to lasti
      x = Get time from index... i
      y = Get value at index... i
      if (y > ymax) 
         y = ymax+1
      elsif (y < ymin)
         y = ymin-1
      endif
      Remove point... i
      Add point... x y
   endfor
endproc 


# Delete temporary objects created for current input file
procedure cleanup_current_file
   if (signal_available)
      select soundID
      if (volatile)
         plus fullsoundID
      endif
      Remove
      signal_available = 0
   endif
   dummy = Create TextGrid... 0 1 dummy dummy
   select dummy
   if (intensity_available)
      plus intensityID
   endif
   if (pitch_available)
      plus pitchID
   endif
   if (vuv_available)
      plus vuvgridID
   endif
   if (loudness_available)
      plus loudnessID
   endif
   if (intbp_available)
      plus intbpID
   endif
   if (inthp_available)
      plus inthpID
   endif
   if (segfile_available)
      if not boundary_annotation
	 plus segmentationID
      endif
      if (nrofplottedtiers > 0)
	 plus newgridID
      endif
   endif
   if (need_stylization or task == task_segmentation)
      plus nucleiID
   endif
   if (need_stylization)
        # Table with pitch values used in contour_analysis
         if (nucldat_available)
            plus nucldatID
         endif
      ; plus vuvgridID
      plus stylID
      plus stylSTID
   endif
   Remove
endproc


procedure cleanup_global
   if (task != task_interactive and task != task_annotation)
   # Global report
     filedelete 'globalfile$'
     if (need_prosodic_profile and needs_pitchrange)
	call msg Writing global profile report to "'globalfile$'"
        select reportID
        Write to headerless spreadsheet file... 'globalfile$'
     endif
   endif
   select reportID
   Remove
   if (use_filelist)
      select Strings filelist
      Remove
   endif
endproc


procedure convert_sampa_ipa objectID tier
   select objectID
   n_ = Get number of intervals... tier
   for j from 1 to n_
      label$ = Get label of interval... tier j
      call sampa_ipa
      Set interval text... tier j 'label$'
   endfor
endproc


# replace SAMPA label$ by IPA representation in Praat's "special symbols" format
procedure sampa_ipa
   len = length (label$)
   s$ = ""
   i = 1
   while (i <= len)
      b$ = ""			; translation
      c1$ = mid$ (label$,i,1)	; next char
      c2$ = mid$ (label$,i,2)	; next 2 chars
      c3$ = mid$ (label$,i,3)	; next 3 chars
      c4$ = mid$ (label$,i,4)	; next 4 chars
      cn$ = mid$ (label$,i+1,1)	; following char
      restlen = len - i
      if (restlen >= 1 and (cn$ = "~" or cn$ = "`" or cn$ = "="))
         if (cn$ = "~")		; nasal vowels (length=2)
            if (c2$ = "a~")
               b$ = "a\~^"
            elsif (c2$ = "A~")
               b$ = "\as\~^"
            elsif (c2$ = "o~")
               b$ = "\o~"
            elsif (c2$ = "E~" or c2$ = "e~") 
               b$ = "\ep\~^"
            elsif (c2$ = "O~")
               b$ = "\ct\~^"
            elsif (c2$ = "9~")
               b$ = "\oe\~^"
            endif
         elsif (cn$ = "`")	; rhoticity
            if (index ("uoi", c1$)) 
               b$ = c1$ + "\hr"
            elsif (c2$ = "@`") 
               b$ = "\sr"
            elsif (c2$ = "s`") 
               b$ = "\s."
            elsif (c2$ = "z`") 
               b$ = "\z."
            endif
         elsif (cn$ = "=")	; syllabicity in x-sampa
            if (index_regex (c1$, "[mnNJlrR]")) 
               b$ = c1$ + "\|v"
            endif
         endif
	 if (length (b$) > 0)
            s$ = s$ + b$
            i += 2
         else
            s$ = s$ + c1$
	    i += 1
         endif
    # SAMPA symbols of length 1
      elsif (index ("SZRMNHJGAEIOQVY@2679?:{}&", c1$))
         if (c1$ = "A") 
            b$ = "\as"
         elsif (c1$ = "E")
            b$ = "\ep"
         elsif (c1$ = "I")
            b$ = "\ic"
         elsif (c1$ = "O")
            b$ = "\ct"
         elsif (c1$ = "Y")
            b$ = "\yc"
         elsif (c1$ = "Q")
            b$ = "\ab"
         elsif (c1$ = "V")
            b$ = "\vt"
         elsif (c1$ = "2")
            b$ = "\o/"
         elsif (c1$ = "6")
            b$ = "\sr"
         elsif (c1$ = "7") 
            b$ = "\rh"
         elsif (c1$ = "9") 
            b$ = "\oe"
         elsif (c1$ = "@") 
            b$ = "\sw"
         elsif (c1$ = "S") 
            b$ = "\sh"
         elsif (c1$ = "Z") 
            b$ = "\zh"
         elsif (c1$ = "R") 
            b$ = "\rc"
         elsif (c1$ = "M") 
            b$ = "\mj"
         elsif (c1$ = "N") 
            b$ = "\ng"
         elsif (c1$ = "H") 
            b$ = "\ht"
         elsif (c1$ = "J") 
            b$ = "\nj"
         elsif (c1$ = "G") 
            b$ = "\gf"
         elsif (c1$ = "?") 
            b$ = "\?g"
         elsif (c1$ = ":") 
            b$ = "\:f"
         elsif (c1$ = "{") 
            b$ = "\ae"
         elsif (c1$ = "}") 
            b$ = "\u-"
         elsif (c1$ = "&") 
            b$ = "\Oe"
         endif
         if (length (b$) > 0)
            s$ = s$ + b$	; append b$ to output string
            i += 1
         else
            s$ = s$ + c1$
	    i += 1
         endif
      elsif (restlen >= 3 and index (":\a~:\o~:\o/:", c3$) > 0)
            s$ = s$ + c3$
            i += 3
      elsif (c3$ = "i_d")
            s$ = s$ + "i\Nv"
            i += 3
      elsif (restlen >= 4 and index (":\ep~:", c4$) > 0)
            s$ = s$ + c4$
            i += 4
      else			; others: just copy them
         s$ = s$ + c1$
	 i += 1
      endif
   endwhile
   label$ = s$
endproc


;procedure get_pitchrange paramID nucleiID atime1 atime2 use_ST
;# Make histogram of stylization targets within nuclei to find central range
;   if (use_ST)		; using values in ST
;      call histogram_create 50 50 150
;   else			; using values in Hz
;      call histogram_create 80 50 400
;   endif
;   h = result
;   call interval_from_time nucleiID nucleus_tier atime1 first_interval
;   call interval_from_time nucleiID nucleus_tier atime2 last_interval
;   for interv from first_interval to last_interval
;      select nucleiID
;      label$ = Get label of interval... nucleus_tier interv
;      if (label$ = "a")						; a valid nucleus
;         nx1 = Get starting point... nucleus_tier interv	; start of nucleus
;         nx2 = Get end point... nucleus_tier interv		; end of nucleus
;         select paramID						; stylization
;         i1 = Get nearest index from time... nx1
;         i2 = Get nearest index from time... nx2
;         for i from i1 to i2-1				; each stylization segment
;            select paramID
;            y = Get value at index... i
;            call histogram_addvalue h y
;            if (i == i2-1)
;               select paramID
;               y = Get value at index... i+1
;               call histogram_addvalue h y
;            endif
;	 endfor
;      endif
;   endfor
;   call histogram_getcount h
;   count = result
;;printline pitchrange count='count' 
;      if (count > 2)			; need minimum targets in time interval
;         call histogram_quantile h 0.1
;         pct10 = result
;         call histogram_quantile h 0.5
;         pct50 = result
;         call histogram_quantile h 0.9
;         pct90 = result
;         call histogram_quantile h 0.05
;         pct05 = result
;         call histogram_quantile h 0.95
;         pct95 = result
;;printline pitchrange 05='pct05:3' 10='pct10:3' 50='pct50:3' 90='pct90:3' 95='pct95:3' 
;      else	; ad hoc for signal/test with 1 syllable
;         select pitchID
;         pct50 = Get mean... 0 0 Hertz
;         ;pct05 = pct50 - 12
;      endif
;   call histogram_remove h
;endproc


procedure speaker_info_get
# 1. Make list of speakers appearing in tier "speaker" of annotated segmentation textgrid.
# 2. Add speaker identification to nucldatID, as a number (in column <speaker_id>) and as a string (in row label).
   speakers = 0			; nrof different speakers found
   speakers$ = ""		; used to store speaker names and their number
   if (speaker_available)
       speaker = 0		; nrof current speaker
       select nucldatID
       rows = Get number of rows
       for row to rows
          t1 = Get value... row nucleusstarttime
          t2 = Get value... row nucleusendtime
          select nucleiID
	  i = Get interval at time... speaker_tier t1+(t2-t1)/2
          speaker$ = Get label of interval... speaker_tier i
          speaker$ = replace_regex$ (speaker$, "^ +(.*) +$", "\1", 1)	; trim left and right
          if (index (speakers$, "<'speaker$'>") > 0)			; speaker already encountered in file
             speaker = extractNumber (speakers$, "<'speaker$'>:")	; get his number
          else								; new speaker
             speakers += 1	; found new speaker
	     speaker = speakers	; its number
             speakers$ = speakers$ + "<'speaker$'>:'speaker' "	; store name and number in list
             speaker_label'speaker'$ = speaker$
	  endif
          select nucldatID
          Set value... row speaker_id speaker
          ; speaker$ = replace_regex$ (speaker$, " ", "_", 0)
          if (length(speaker$) < 1)
             ; speaker$ = "_"
          endif
          Set row label (index)... row "'speaker$'"
       endfor
   else
      call msg Input textgrid does not contain speaker tier. Assuming there's 1 speaker.
      speakers = 1
      speaker$ = "ANON"
      speaker_label'speakers'$ = speaker$
      speakers$ = "<'speaker$'>:'speakers' "
      select nucleiID
      Set interval text... speaker_tier 1 'speaker$'
      select nucldatID
      rows = Get number of rows
      for row from 1 to rows
         Set value... row speaker_id 1
      endfor
   endif
endproc


procedure speaker_autorange t1 t2
; propose a pitch range suitable for all speakers in time range <t1>..<t2>
; return range in ST in <ymin>..<ymax>
   if (task == task_pitch_plot or not needs_pitchrange)	; no nuclei availale
      select pitchID
      y_ = Get mean... t1 t2 semitones re 1 Hz
      ymin = y_ - 12
      ymax = y_ + 12
   else ; compute total range for all speakers in time interval <t1>..<t2>
      ymin = 1000 
      ymax = 0
      t_ = t1
      select nucleiID
      t2_ = Get end time
      t2_ = min (t2, t2_)
      repeat
         i = Get interval at time... speaker_tier t_
         speaker$ = Get label of interval... speaker_tier i
         speaker$ = replace_regex$ (speaker$, "^ +(.*) +$", "\1", 1)	; trim left and right
         speaker_j = extractNumber (speakers$, "<'speaker$'>:")		; get his number
         if (speaker_j == 0 or speaker_j == undefined)
            ; call msg speaker_autorange: speaker undefined at time 't_:3'
            ; This happens when there are no nuclei for this speaker 
            select pitchID
            ymin = Get mean... 0 0 semitones re 1 Hz
            ymax = ymin
         else
            y_ = extractNumber (speaker_range_'speaker_j'$, "BOTTOM_ST=")
            ymin = min (ymin, y_) 
            y_ = extractNumber (speaker_range_'speaker_j'$, "TOP_ST=")
            ymax = max (ymax, y_)
;call msg speaker_autorange: t1='t_:3' t2='t2_:3' speaker='speaker_j' total range ymin='ymin:1' ymax='ymax:1'
         endif
         select nucleiID
         t_ = Get end point... speaker_tier i
      until (t_ >= t2_)
      if (ymax - ymin < 24)		; default range 24 ST or 2 octaves 
         ymin = max(0, (ymin + (ymax - ymin)/2) - 12)
         ymax = ymin + 24
      endif
   endif ; task
endproc


procedure nucleus_tier_postproc grid_ phon_tier_ syll_tier_
   select grid_
   interval_tier = Is interval tier... phon_tier_
   if (interval_tier)
      Set tier name... phon_tier_ x
      n_ = Get number of intervals... phon_tier_
      ; replace parts other than nucleus by zero-length strings
      for i_ to n_
         s_$ = Get label of interval... phon_tier_ i_
         s_$ = ":'s_$':"
         if (index (":<:>:<>:xL:xR:U:skip:reject:short:", s_$) > 0)
            s_$ = ""
            Set interval text... phon_tier_ i_ 's_$'
         endif
      endfor
      ; reduce contiguous empty intervals
      i_ = 2
      while (i_ <= n_)
         prev_$ = Get label of interval... phon_tier_ i_-1
         s_$ = Get label of interval... phon_tier_ i_
         if (prev_$ = "" and s_$ = "")
            Remove left boundary... phon_tier_ i_
            n_ -= 1
         else
            i_ += 1
         endif
      endwhile
      ; add syllable boundaries to nucleux tier
      empty$ = ""
      n_ = Get number of intervals... syll_tier_
      for i_ to n_ - 1
         t_ = Get end point... syll_tier_ i_
         j_ = Get interval at time... phon_tier_ t_
         x1_ = Get start point... phon_tier_ j_
         x2_ = Get end point... phon_tier_ j_
         if (t_ - x1_ > time_step and t_ < x2_)
            Insert boundary... phon_tier_ t_
	 endif
         Set interval text... syll_tier_ i_ 'empty$'
      endfor
   endif
endproc

