# prosoplot.praat ---
# Praat include file containing some procedures for plotting
# Author: Piet Mertens
# Last modification: 2012-03-27


procedure gr_init
   demowin = 0
   grey$ = "Grey"
   red$ = "Red"
   green$ = "Green"
   blue$ = "Blue"
   cyan$ = "Cyan"
   purple$ = "Purple"
   magenta$ = "Magenta"
   pink$ = "Pink"
   purple$ = "Purple"
   if (greyscale)
      red$ = "Black"
      green$ = "Black"
      blue$ = "Black"
      cyan$ = "Grey"
      purple$ = "Grey"
      magenta$ = "Grey"
      pink$ = "Grey"
      purple$ = "Grey"
   endif
endproc


procedure gr_start_picturewin
   win$ = ""
   # Font size affects display of TextGrid.
   'font_family$'
   fontsize = 10
   small_fontsize = 6 ; used for file stamp
   tiny_fontsize = 4 ; used for version stamp
   stylization_linewidth = 7
   default_fontsize = 10
   Font size... default_fontsize
endproc


procedure gr_start_demowin
   demowin = 1
   demoWindowTitle (version$)
   win$ = "demo "
   grid_in_prosogram = 0
   fontsize = 10
   small_fontsize = 8
   tiny_fontsize = 6
   default_fontsize = 10
   'win$''font_family$'
   'win$'Font size... default_fontsize
   stylization_linewidth = 3
   'win$'Black
   'win$'Select outer viewport... 0 100 0 100
   'win$'Select inner viewport... 0 100 0 100
   'win$'Axes... 0 100 0 100
   gr_text_maxlines = 40
   call gr_clearscreen
endproc


procedure gr_printline text_$
   if (demowin > 0)
      yd_ = 100/gr_text_maxlines 
      xt_ = 1
      if (gr_text_linenr >= gr_text_maxlines)
         for j from 1 to gr_text_maxlines-1
            gr_textbuf'j'$ = gr_textbuf'j+1'$
            s_$ = gr_textbuf'j'$
            s_$ = replace$ (s_$, "_", "\_ ", 0)
            xt2_ = Text width (wc)... 's_$'
            'win$'Paint rectangle... White xt_ xt2_ yt_ yt_+yd_
	    yt_ = 100 - (j * yd_) 
            'win$'Text special... xt_ left yt_ bottom Helvetica fontsize 0 's_$'
         endfor
         gr_text_linenr = gr_text_maxlines
      else
      endif
      yt_ = 100 - (gr_text_linenr * yd_) 
      s_$ = replace$ (text_$, "_", "\_ ", 0)
      'win$'Text special... xt_ left yt_ bottom Helvetica fontsize 0 's_$'
      gr_textbuf'gr_text_linenr'$ = text_$
      gr_text_linenr += 1
   else
      printline 'text_$'
   endif
endproc


procedure gr_clearscreen
   'win$'Erase all
   for j from 1 to gr_text_maxlines
      gr_textbuf'j'$ = ""
   endfor
   gr_text_linenr = 1
endproc


procedure gr_run_demowin anal_t1 anal_t2 timeincr ySTmin ySTmax
# viewport for prosogram (below buttons)
   dw_ovx1 = 0			; outer viewport
   dw_ovx2 = 100
   dw_ovy1 = 60
   dw_ovy2 = 91
   dw_margin = 5
   dw_vx1 = dw_ovx1 + dw_margin	; inner viewport
   dw_vx2 = dw_ovx2 - dw_margin
   dw_vy1 = dw_ovy1 + dw_margin
   dw_vy2 = dw_ovy2 - dw_margin
# viewport for buttons
   dw_bx1 = dw_vx1	; inner viewport
   dw_bx2 = dw_vx2
   dw_by1 = 93
   dw_by2 = 98
# viewport for separate textgrid
   dw_Tx1 = dw_vx1	; inner viewport
   dw_Tx2 = dw_vx2
   dw_Ty1 = dw_vy1	; default when no textgrid 
   dw_Ty2 = dw_vy2	; default when no textgrid
   if (nrofplottedtiers > 0)
      select newgridID
      n_ = Get number of tiers
      dw_Ty2 = dw_vy1 - 1
      dw_Ty1 = dw_Ty2 - (5 * n_) 
      ; printline T x1=<'dw_Tx1:1'> x2=<'dw_Tx2:1'> y1=<'dw_Ty1:1'> y2=<'dw_Ty2:1'>
   endif
# display prosogram
   'win$'Erase all
   call gr_redraw anal_t1 anal_t1+timeincr 
   call gr_on_input nucleiID
endproc


procedure gr_redraw x1_ x2_
   call gr_display_prosogram x1_ x2_ ySTmin ySTmax grid_in_prosogram
   if (nrofplottedtiers > 0)
      call gr_display_textgrid_pure newgridID x1_ x2_ dw_Tx1 dw_Tx2 dw_Ty1 dw_Ty2
   endif
   call gr_draw_buttons Black
endproc


procedure gr_display_prosogram x1 x2 y1 y2 with_grid
;printline gr_display_prosogram: x1='x1:3' y1='y1:1' y2='y2:1'
 # used in Picture window or Demo window
   if (demowin) ; clear demo window
      'win$'Select inner viewport... dw_ovx1 dw_ovx2 dw_ovy1 dw_ovy2
      'win$'Axes... dw_ovx1 dw_ovx2 dw_ovy1 dw_ovy2
      'win$'Paint rectangle... White dw_ovx1 dw_ovx2 dw_ovy1 dw_ovy2 
      'win$'Select inner viewport... dw_vx1 dw_vx2 dw_vy1 dw_vy2
   endif
   ySTmax = y2
   ySTmin = y1
   if (with_grid)
      ySTbottom = ySTmin - nrofplottedtiers*(ySTmax-ySTmin)/4
   else
      ySTbottom = y1
   endif
   'win$'Axes... x1 x2 ySTbottom ySTmax
# start drawing
   if (with_grid and newgrid_available and nrofplottedtiers > 0)	; textgrid available
      call gr_plot_textgrid newgridID x1 x2
   endif
   call gr_garnish x1 x2 ySTbottom ySTmin ySTmax 10 'basename$'
   if (task != task_annotation)
      # Adjust plotted intensity range such that distance between horizontal lines = 3 dB
         select intensityID
         dBmin = Get minimum... signal_start anal_t2 Parabolic
         dBmax = Get maximum... signal_start anal_t2 Parabolic
         # divide range by 2, since distance between lines = 2ST
         dBmin = dBmax - ((ySTmax - ySTmin)/2) * 3
      call gr_draw_portee x1 x2 ySTmin ySTmax 2 ySTbottom
      if (need_stylization)
         call gr_draw_octavejump nucleiID discontinuity_tier x1 x2 'red$'
      endif
      if (rich or task == task_pitch_plot)
         call gr_plot_param_ST pitchID x1 x2 ySTbottom ySTmax 'blue$'
      endif
      if (rich)
         if (show_intensity)
            call gr_plot_param_scaled intensityID x1 x2 1 'green$'
         endif
         if (intbp_available and show_intbp)
            call gr_plot_param_scaled intbpID x1 x2 1 'magenta$'
         endif
         if (loudness_available)
            select loudnessID
            min = Get minimum... signal_start anal_t2 Parabolic
            max = Get maximum... signal_start anal_t2 Parabolic
            tmp = min - nrofplottedtiers*(max-min)/4
            call gr_plot_param loudnessID x1 x2 tmp max 'cyan$'
         endif
         if (show_harmonicity)
            call gr_plot_param_scaled harmonicityID x1 x2 0 'purple$'
         endif
         if (show_vuv)
            call gr_plot_vuv nucleiID vuv_tier x1 x2 Black
         endif
         if (need_stylization)
            call gr_plot_nuclei nucleiID x1 x2 'red$'
         endif
         if (show_lengthening)
            call gr_plot_lengthening nucleiID x1 x2 'grey$'
         endif
         if (show_pitchrange)
            call gr_plot_pitchrange nucleiID x1 x2 'magenta$'
         endif
      endif ; rich
   
      if (plot_pauses)
         call gr_plot_feature nucleiID nucldatID j_before_pause time1 time2 "Right" 75 "P" Red
      endif
      if (contour_annotation) 
         call gr_plot_feature nucleiID nucldatID j_hesitation time1 time2 "Centre" 60 "H" Blue
      endif
      if ((boundary_annotation or stress_annotation) and show_prominence)
        call plot_prominence_measures x1 x2
      endif
   
      if (need_stylization)
         call gr_plot_PitchTier_clip_nuclei stylSTID nucleiID x1 x2 ySTbottom ySTmax draw_pitch_target_values Black
      endif
   endif
endproc


procedure gr_display_textgrid_pure gridID_ x1_ x2_ vpx1_ vpx2_ vpy1_ vpy2_
; Draw textgrid rather than using Draw command
   'win$'Select inner viewport... vpx1_ vpx2_ vpy1_ vpy2_
   'win$'Axes... vpx1_ vpx2_ vpy1_ vpy2_
   ; Clear the area
   'win$'Paint rectangle... White vpx1_ vpx2_ vpy1_ vpy2_ 
   'win$'Black
   'win$'Line width... 1
   'win$'Solid line
   select gridID_
   n_ = Get number of tiers
   y1_ = 0
   y2_ = 1
   dyN_ = (y2_ - y1_)/n_
   'win$'Axes... x1_ x2_ y1_ y2_
   'win$'Draw inner box
   for tier_ from 1 to n_
      ylo_ = (n_ - tier_) * dyN_
      yhi_ = ylo_ + dyN_
      'win$'Draw line... x1_ yhi_ x2_ yhi_
      call interval_from_time gridID_ tier_ x1_ i1_
      call interval_from_time gridID_ tier_ x2_ i2_
      for interval_ from i1_ to i2_
         ix1_ = Get starting point... tier_ interval_
         ix2_ = Get end point... tier_ interval_
         ix1_ = max (ix1_, x1_)
         ix2_ = min (ix2_, x2_)
	 label_$ = Get label of interval... tier_ interval_
         'win$'Draw line... ix2_ ylo_ ix2_ yhi_
         xt_ = ix1_ + (ix2_ - ix1_)/2
         yt_ = ylo_ + (yhi_ - ylo_)/2
	 'win$'Text special... xt_ centre yt_ half Helvetica fontsize 0 'label_$'
      endfor
   endfor
endproc


procedure gr_on_input gridID
   'win$'Select inner viewport... 0 100 0 100
   'win$'Axes... 0 100 0 100
   loop = 1
 while (loop and demoWaitForInput ( ))
   if demoClicked ( ) 
      x0 = demoX ( )
      y0 = demoY ( )
      if demoClickedIn (dw_vx1, dw_vx2, dw_vy1, dw_vy2)		; clicked on prosogram
         x = x1 + ((x0-dw_vx1) / (dw_vx2-dw_vx1)) * (x2-x1)  
         call interval_from_time gridID nucleus_tier x interval
         t1 = Get starting point... nucleus_tier interval
         t2 = Get end point... nucleus_tier interval
         call play_part soundID t1 t2
      elsif demoClickedIn (dw_Tx1, dw_Tx2, dw_Ty1, dw_Ty2)	; clicked textgrid
         x = x1 + ((x0-dw_Tx1) / (dw_Tx2-dw_Tx1)) * (x2-x1)
         if (nrofplottedtiers > 0)
            select newgridID
            n_ = Get number of tiers
            tier = ceiling ((y0-dw_Ty1)/((dw_Ty2-dw_Ty1)/n_))
            tier = min( max (1, tier), n_)
            tier = n_ - tier + 1		; tiers drawn from top to bottom
            call interval_from_time newgridID tier x interval
            t1 = Get starting point... tier interval
            t2 = Get end point... tier interval
            call play_part soundID t1 t2
         endif
      elsif demoClickedIn (dw_bx1, dw_bx2, dw_by1, dw_by2)	; clicked buttons
         button = 0
	 for j from 1 to nrof_buttons
            if demoClickedIn (button'j'_x1, button'j'_x2, dw_by1, dw_by2)
               button = j
               j = nrof_buttons + 1
            endif
         endfor
	 if (button == 1)
            call gr_scroll 0
	 elsif (button == 2)
            call gr_scroll -timeincr
	 elsif (button == 3)
            call gr_scroll -0.25
	 elsif (button == 4)
            call gr_scroll 0.25
	 elsif (button == 5)
            call gr_scroll timeincr
	 elsif (button == 6)
            call gr_scroll anal_t2
 	 elsif (button == 7)
            call gr_zoom 2
 	 elsif (button == 8)
            call gr_zoom 0.5
 	 elsif (button == 10)
            call gr_draw_button 10 Lime Play~Window
            call play_part soundID x1 x2
            call gr_draw_button 10 Yellow Play~Window
 	 elsif (button == 11)
            call gr_draw_button 11 Lime Resynth
            call resynthesis soundID stylID time_step x1 x2
            call gr_draw_button 11 Yellow Resynth
 	 elsif (button == 13)
            call toggle draw_pitch_target_values  
	    call gr_redraw x1 x2
 	 elsif (button == 16)
            call gr_clearscreen
	    call gr_printline Now kill window...
	    loop = 0
         endif
      endif
   elsif demoKeyPressed ( )
      key$ = demoKey$ ( )
      if (key$ = "R")      
         call gr_scroll timeincr
      elsif (key$ = "L")        
         call gr_scroll -timeincr
      ;else
      ;   shift = demoShiftKeyPressed ()
      ;   printline KeyPressed='key$' shift='shift' 
      endif
   endif
   'win$'Select inner viewport... 0 100 0 100
   'win$'Axes... 0 100 0 100
 endwhile
endproc


procedure resynthesis soundinID pitchtierinID time_step x1 x2
   ; Make a copy of part of the pitch tier
   select pitchtierinID		; values in Hz
   j1 = Get high index from time... x1
   j2 = Get low index from time... x2
   tmppitchtierID = Create PitchTier... tmp x1 x2
   for j_ from j1 to j2
      select pitchtierinID
      y_ = Get value at index... j_
      t_ = Get time from index... j_
      select tmppitchtierID
      Add point... t_ y_
   endfor
   ; Make a copy of part of the speech signal and get resynthesis
   select soundinID
   tmpsoundID = Extract part... x1 x2 rectangular 1.0 yes 
   manipID = To Manipulation... time_step 60 600
   select tmppitchtierID
   plus manipID
   Replace pitch tier
   select manipID
   synthID = Get resynthesis (overlap-add)
   ; Plot PitchTier
   call gr_plot_PitchTier stylSTID x1 x2 Lime
   select synthID
   Play
   ; Write to WAV file... tmp_resynth.wav
   select manipID
   plus tmppitchtierID
   plus tmpsoundID
   plus synthID
   Remove
   call gr_display_prosogram x1 x2 ySTmin ySTmax grid_in_prosogram
endproc


procedure gr_draw_buttons color_$
   nrof_buttons = 16 ; room for 16 buttons of equal size (1 row horizontally)
   ; printline draw buttons x1=<'dw_bx1:1'> x2=<'dw_bx2:1'> y1=<'dw_by1:1'> y2=<'dw_by2:1'>
   'win$'Select inner viewport... dw_bx1 dw_bx2 dw_by1 dw_by2
   'win$'Axes... dw_bx1 dw_bx2 dw_by1 dw_by2
   # Clear the buttons area
   'win$'Paint rectangle... White dw_bx1 dw_bx2 dw_by1 dw_by2
   # Define button positions
   size = (dw_bx2-dw_bx1)/nrof_buttons
   for j to nrof_buttons
      button'j'_x1 = dw_bx1 + (j-1)*size + size*0.1
      button'j'_x2 = button'j'_x1 + size*0.9
   endfor
   call gr_draw_button 1 Yellow |<<
   call gr_draw_button 2 Yellow <<
   call gr_draw_button 3 Yellow <
   call gr_draw_button 4 Yellow >
   call gr_draw_button 5 Yellow >>
   call gr_draw_button 6 Yellow >>|
   call gr_draw_button 7 Yellow Zoom~Out
   call gr_draw_button 8 Yellow Zoom~In
   call gr_draw_button 10 Yellow Play~Window
   call gr_draw_button 11 Yellow Resynth
   call gr_draw_button 13 Yellow Show~Values
   call gr_draw_button 16 Yellow Exit
endproc


procedure gr_draw_button nr color_$ text$
   x1_ = button'nr'_x1
   x2_ = button'nr'_x2
   x_ = x1_ + (x2_ - x1_)/2
   y_ = dw_by1 + (dw_by2 - dw_by1)/2
   ;printline button 'nr' x1='x1_:1' x2='x2_:1' dw_by1='dw_by1:1' dw_by2='dw_by2:1' x='x_:1' y='y_:1'
   ;printline gr_draw_button 'nr' color_='color_$'
   'win$'Select inner viewport... dw_bx1 dw_bx2 dw_by1 dw_by2
   'win$'Axes... dw_bx1 dw_bx2 dw_by1 dw_by2
   'win$'Paint rectangle... 'color_$' x1_ x2_ dw_by1 dw_by2
   'win$'Black
   'win$'Draw rectangle... x1_ x2_ dw_by1 dw_by2
   pos_ = index (text$, "~")
   if (pos_ > 0)
      s_$ = left$ (text$, pos_ - 1)
      'win$'Text special... x_ centre y_ bottom Helvetica fontsize 0 's_$'
      s_$ = right$ (text$, length(text$) - pos_)
      'win$'Text special... x_ centre y_ top Helvetica fontsize 0 's_$'
   else
      'win$'Text special... x_ centre y_ half Helvetica fontsize 0 'text$'
   endif
endproc


procedure gr_zoom factor
   x_ = x1 + (x2-x1)/2
   timeincr = max (1, factor * timeincr)
   x1 = max (x_ - timeincr/2, anal_t1)
   x2 = min (x_ + timeincr/2, anal_t2)
   timeincr = x2-x1
   call gr_redraw x1 x2
endproc


procedure gr_scroll amount
   if (amount = 0)
      x1 = anal_t1
   endif
   x1 = min (x1 + amount, anal_t2 - timeincr)
   x1 = max (x1, anal_t1)
   x2 = min (x1 + timeincr, anal_t2)
   call gr_redraw x1 x2
endproc


procedure gr_draw_portee x1 x2 ySTmin ySTmax ySTstep ySTbottom
# Draw horizontal calibration lines which are ySTstep apart
# from ySTbottom to YSTmax, using CURRENT world definition
   'win$'Axes... x1 x2 ySTbottom ySTmax
   # Draw calibration lines
      'win$'Grey
      'win$'Line width... 1
      'win$'Dotted line
      yST = ySTmin
      i = 0
      while (yST < ySTmax)
        'win$'Draw line... x1 yST x2 yST
        yST = yST + ySTstep
      endwhile
    # Show 150 Hz reference
      y = -1.0 * hertzToSemitones(1) + hertzToSemitones(150)
      x = x1 + (x2-x1) / 60
      'win$'Red
      'win$'Solid line
      'win$'Draw arrow... x y x1 y
      'win$'Text special... x1 Right y Half Helvetica small_fontsize 0 150 Hz 
endproc


procedure gr_plot_textgrid gridID_ x1 x2
   if (demowin)
      'win$'Select inner viewport... dw_vx1 dw_vx2 dw_vy1 dw_vy2
   endif
   'win$'Black
   'win$'Line width... 1
   'win$'Solid line
   select gridID_
   # Draw... From To ShowBoundaries UseTextstyles Garnish
   if (task == task_annotation)
      'win$'Draw... x1 x2 no no no
   else
      'win$'Draw... x1 x2 yes no no
   endif
endproc


procedure gr_garnish x1 x2 ybot y1 y2 ystep string$
; Y axis on ST scale : ybot = bottom of textgrid, y1 = bottom of drawing, y2 = top of drawing
   'win$'Black
   'win$'Line width... 1
   'win$'Solid line
   'win$'Axes... x1 x2 ybot y2
   'win$'Draw inner box
 # Time calibration marks
   'win$'Marks top every... 1 0.1 no yes no
   'win$'Marks top every... 1 1 yes yes no
 # Y axis calibration
   if (task != task_annotation)
      if (demowin)
         'win$'Marks left every... 1 ystep yes yes no
      else	; only use area without textgrid
;         vy_ = vy1 + (vy2-vy1) * ((y1-ybot)/(y2-ybot)) 
;         Select inner viewport... vx1 vx2 vy1 vy_
;        'win$'Axes... x1 x2 y1 y2
         'win$'Marks left every... 1 ystep yes yes no
;         Select inner viewport... vx1 vx2 vy1 vy2
;         'win$'Axes... x1 x2 ybot y2
         y_ = (floor(y2/ystep) * ystep) - (ystep/2)
         'win$'Text special... x1 right y_ half Helvetica small_fontsize 0.0 ST 
      endif
   endif
   if (task != task_annotation and task != task_pitch_plot)
    # Show analysis settings : segmentation mode, glissando threshold
       if (adaptive_glissando)
          s$ = "G(adapt)='glissando_low'-'glissando'/T^2"
       else
          s$ = "G='glissando'/T^2"
       endif
       s$ = "'segmentation_name$', " + s$ + ", DG='diffgt', dmin='mindur_ts:3'"
       'win$'Text special... x2 Right y2 Top Helvetica small_fontsize 0.0 's$' 
   endif
   if (not demowin)
    # Print version identification
         'win$'Text special... x2 Right ybot Top Helvetica tiny_fontsize 0.0 'version$'
    # Show end of signal by double vertical line
      if (x2 > signal_finish)
         'win$'Line width... 3
         'win$'Draw line... signal_finish ybot signal_finish y2
         x = signal_finish + (x2-x1)/200
         'win$'Draw line... x ybot x y2
         'win$'Line width... 1
      endif
      if (nrofFiles > 1 or file_stamp > 0)
         if (file_stamp > 0)
            s$ = replace$(string$, "_", "\_ ", 0)
            if (view < 3)
               s$ = "'s$' ('x1:2'-'x2:2's)"
            endif
            Text special... time1 Left ybot Top Helvetica small_fontsize 0.0 's$'
         endif
      endif
   endif
endproc


procedure gr_plot_param_ST paramID x1 x2 y1 y2 color_$
   'win$''color_$'
   select paramID
   # diffST = difference in ST between ST-scale relative to 100Hz and that rel to 1Hz
   diffST = 12 * log2(100/1)
   'win$'Draw semitones... x1 x2 'y1'-diffST 'y2'-diffST no
endproc


procedure gr_plot_param paramID x1 x2 y1 y2 color_$
# Plot parameter paramID in current viewport 
   'win$''color_$'
   'win$'Line width... 1
   select paramID
   'win$'Draw... x1 x2 y1 y2 no
endproc


procedure gr_plot_param_scaled paramID x1_ x2_ garnish color_$
   'win$''color_$'
   'win$'Line width... 1
   select paramID
   y2_ = Get maximum... anal_t1 anal_t2 Parabolic
   y1_ = y2_ - ((ySTmax - ySTmin)/2) * 3
   if (with_grid)
      y1_ -= nrofplottedtiers*(y2_-y1_)/4
   endif
   if (garnish)		; objects for which Draw includes "garnish" option
      'win$'Draw... x1_ x2_ y1_ y2_ no
   else
      'win$'Draw... x1_ x2_ y1_ y2_
   endif
endproc


procedure gr_draw_zigzag lx1 lxend ldx lystart ldy
# Draw a horizontal zigzag line from <lx1> to <lxend>, with x-steps of <ldx> 
# starting from <lystart> moving up by <ldy> and back to <lystart> 
   ldir = 1 ; up
   ly1 = lystart - ldy/2
   ly2 = lystart + ldy/2
   while (lx1 < lxend)
      lx = lx1 + ldx
      if (lx > lxend)
         lx = lxend
         ly2 = ly1 + ldir*(ldy*(lx-lx1)/ldx)
      endif
      'win$'Draw line... lx1 ly1 lx ly2
      lx1 += ldx
      ldir = ldir * -1 ; change direction
      tmp = ly1
      ly1 = ly2
      ly2 = tmp
   endwhile
endproc


procedure gr_plot_vuv gridID tier_ x1 x2 color_$
# Draw VUV data contained in tier 1 of <gridID>, from time <x1> to <x2>
   ldx = (x2 - x1) / 200
   ldy = (ySTmax - ySTbottom) / 50
   ly = ySTmin + ldy
   ly_1 = ly - ldy/2
   ly_2 = ly + ldy/2
   'win$'Axes... x1 x2 ySTbottom ySTmax
   select gridID
   ni = Get number of intervals... tier_
   call interval_from_time gridID tier_ x1 first_interval
   call interval_from_time gridID tier_ x2 last_interval
   'win$''color_$'
   for i from first_interval to last_interval
      label$ = Get label of interval... tier_ i
      if (label$ = "V")
         t1 = Get starting point... tier_ i
         t2 = Get end point... tier_ i
	 if (t1 >= x1)
             'win$'Draw line... t1 ly_1 t1 ly_2
	 endif
         if (t2 <= x2)
             'win$'Draw line... t2 ly_1 t2 ly_2
	 endif
	 lx1 = max (x1, t1)
         lx2 = min (x2, t2)
         call gr_draw_zigzag lx1 lx2 ldx ly ldy
      endif
   endfor
endproc


procedure gr_plot_nuclei gridID x1 x2 color_$
# Draw nuclei in nucleus_tier of <gridID>, from time <x1> to <x2> at the bottom of the current viewport
   ldy = (ySTmax - ySTbottom) / 50	; divide Y-range in 50 parts
   ly = ySTmin + ldy
   ly_1 = ly - ldy*0.80
   ly_2 = ly + ldy*0.80
   'win$'Axes... x1 x2 ySTbottom ySTmax
   select gridID
   ni = Get number of intervals... nucleus_tier
   call interval_from_time gridID nucleus_tier x1 first_interval
   call interval_from_time gridID nucleus_tier x2 last_interval
   'win$''color_$'
   for i from first_interval to last_interval
      label$ = Get label of interval... nucleus_tier i
      if (label$ = "a")
         t1 = Get starting point... nucleus_tier i
         t2 = Get end point... nucleus_tier i
	 if (t1 >= x1)		; draw left side
             'win$'Draw line... t1 ly_1 t1 ly_2
	 endif
         if (t2 <= x2)		; draw right side
             'win$'Draw line... t2 ly_1 t2 ly_2
	 endif
	 lx1 = max (x1, t1)
         lx2 = min (x2, t2)
         'win$'Draw line... lx1 ly_1 lx2 ly_1
         'win$'Draw line... lx1 ly_2 lx2 ly_2
      endif
   endfor
endproc


procedure gr_plot_pitchrange gridID x1 x2 color_$
# Draw pitchrange using <gridID>, from time <x1> to <x2> in the current viewport
   'win$'Axes... x1 x2 ySTbottom ySTmax
   select gridID
   ni = Get number of intervals... speaker_tier
   call interval_from_time gridID speaker_tier x1 first_interval
   call interval_from_time gridID speaker_tier x2 last_interval
   'win$'Dashed line
   'win$'Line width... 2
   for i from first_interval to last_interval
      t1 = Get start point... speaker_tier i
      t2 = Get end point... speaker_tier i
      if (speaker_available)
         speaker$ = Get label of interval... speaker_tier i
         speaker_j = extractNumber (speakers$, "<'speaker$'>:")	; find speaker number
      else
         speaker_j = 1
      endif
      if (speaker_j == undefined)
         call msg gr_plot_pitchrange: undefined speaker=<'speaker$'> i='i' t1='t1' t2='t2' speakers='speakers$'
      else
         'win$''color_$'
         ly_1 = extractNumber (speaker_range_'speaker_j'$, "BOTTOM_ST=")
         ly_2 = extractNumber (speaker_range_'speaker_j'$, "TOP_ST=")
         if (t1 >= x1)		; draw left side
            'win$'Draw line... t1 ly_1 t1 ly_2
         endif
         if (t2 <= x2)		; draw right side
            'win$'Draw line... t2 ly_1 t2 ly_2
         endif
         lx1 = max (x1, t1)
         lx2 = min (x2, t2)
         'win$'Draw line... lx1 ly_1 lx2 ly_1
         'win$'Draw line... lx1 ly_2 lx2 ly_2
         ly_1 = extractNumber (speaker_range_'speaker_j'$, "MEDIAN_ST=")
         'win$'Draw line... lx1 ly_1 lx2 ly_1
         if (speaker_available)
            s$ = speaker_label'speaker_j'$
            'win$'Text special... lx1 left ly_2 bottom 'font_family$' small_fontsize 0 's$'
         endif
      endif
   endfor
   'win$'Solid line
   'win$'Black
endproc


procedure gr_draw_octavejump nucleiID tier time1 time2 color_$
# Draw octavejumps in tier 2 of <nucleiID>
   'win$''color_$'
   y = ySTmin + (ySTmax - ySTmin) / 2		; y-position to draw
   select nucleiID
   ni = Get number of points... tier
   for i to ni
      x = Get time of point... tier i
      if (x >= time1 and x <= time2)
         'win$'Text... x Centre y Half \ox
      endif
   endfor
endproc


procedure gr_plot_PitchTier_clip_nuclei paramID nucleiID x1 x2 y1 y2 draw_pitch_target_values color_$
   'win$'Axes... x1 x2 y1 y2
   if (clip_to_Y_range)
      select paramID
      tmp_pitchTierID = Copy... tmp_pitchtier
      ; tmp_pitchTierID = selected ("PitchTier", -1)
      select tmp_pitchTierID
      call clipPitchTier tmp_pitchTierID y1 y2 x1 x2
      call gr_plot_stylisation tmp_pitchTierID nucleiID x1 x2 'color_$'
      select tmp_pitchTierID
      Remove
   else
      call gr_plot_stylisation paramID nucleiID x1 x2 draw_pitch_target_values 'color_$'
   endif
endproc


procedure gr_plot_stylisation paramID nucleiID x1 x2 draw_pitch_target_values color_$
# Plot stylization **inside** nuclei
   'win$''color_$'
   call interval_from_time nucleiID nucleus_tier x1 first_interval
   call interval_from_time nucleiID nucleus_tier x2 last_interval
   select paramID					; stylization (PitchTier)
   ni = Get number of points
   for interv from first_interval to last_interval
      select nucleiID
      label$ = Get label of interval... nucleus_tier interv
      if (label$ = "a")						; it's a nucleus
         nx1 = Get starting point... nucleus_tier interv	; time of start of nucleus
         nx2 = Get end point... nucleus_tier interv		; time of end of nucleus
         select paramID						; stylization (PitchTier)
       # Check that the nearest indices are within nucleus
         i1 = Get nearest index from time... nx1
         repeat
            t1 = Get time from index... i1
            if (t1 < nx1)
               i1 += 1
            endif
         until (t1 >= nx1 or t1 >= nx2 or i1 >= ni)
	 i2 = Get nearest index from time... nx2
         repeat
            t2 = Get time from index... i2
            if (t2 > nx2)
               i2 -= 1
            endif
         until (t2 <= nx2 or t2 <= nx1 or i2 <= 1)
         for i from i1 to i2-1				; each stylization segment
            'win$'Line width... stylization_linewidth
	    ox1 = Get time from index... i
            oy1 = Get value at index... i
	    ox2 = Get time from index... 'i'+1
            oy2 = Get value at index... 'i'+1
            if (ox2 > x1 and ox1 < x2)
               ; draw visible part of stylization for tonal segment i 
               lx1 = ox1
               lx2 = ox2
               ly1 = oy1
               ly2 = oy2
               if (ox1 < x1)
                 ly1 = oy1 + (oy2-oy1)*(x1-ox1)/(ox2-ox1)
                 lx1 = x1
               endif
               if (ox2 > x2)
                 ly2 = oy1 + (oy2-oy1)*(x2-ox1)/(ox2-ox1)
                 lx2 = x2
               endif
               'win$'Draw line... lx1 ly1 lx2 ly2
               if (draw_pitch_target_values)
		  offs = 2
                  if (ly1 <> ly2)
                     'win$'Text special... lx1 left ly1+offs half Helvetica small_fontsize 90 'ly1:1'
                     'win$'Text special... lx2 left ly2+offs half Helvetica small_fontsize 90 'ly2:1'
                  else
                     x = lx1 + (lx2-lx1)/2
                     'win$'Text special... x left ly1+offs half Helvetica small_fontsize 90 'ly1:1'
                  endif
               endif
            endif
         endfor
      endif
   endfor
   'win$'Line width... 1
endproc


procedure gr_plot_PitchTier objectID x1 x2 color_$
   if (demowin)
      'win$'Select inner viewport... dw_vx1 dw_vx2 dw_vy1 dw_vy2
   endif
;   ySTmax = y2
;   ySTmin = y1
;   if (with_grid)
;      ySTbottom = ySTmin - nrofplottedtiers*(ySTmax-ySTmin)/4
;   else
;      ySTbottom = y1
;   endif
   'win$'Axes... x1 x2 ySTbottom ySTmax
   select objectID
   'win$''color_$'
   'win$'Draw... x1 x2 ySTmin ySTmax no
endproc

; procedure plot_PitchTier_clip paramID y1 y2 color$
;    select paramID
;    if (clip_to_Y_range > 0)
;       Copy... tmp_pitchtier
;       tmp_pitchTierID = selected ("PitchTier", -1)
;       select tmp_pitchTierID
;       call clipPitchTier tmp_pitchTierID y1 y2 time1 time2
;       Draw... time1 time2 y1 y2 no
;       select tmp_pitchTierID
;       Remove
;    else
;       Draw... time1 time2 y1 y2 no
;    endif
; endproc


procedure gr_plot_values property gridID x1 x2 y1 y2 color_$
# for nuclei in <gridID> in time range <x1>..<x2>, draw value for <property> 
   'win$'Axes... x1 x2 y1 y2
   select gridID
   ni = Get number of intervals... nucleus_tier
   call interval_from_time gridID nucleus_tier x1 first_interval
   call interval_from_time gridID nucleus_tier x2 last_interval
   'win$''color_$'
   for i from first_interval to last_interval
      select gridID
      label$ = Get label of interval... nucleus_tier i
      if (label$ = "a")
         t1 = Get starting point... nucleus_tier i
         t2 = Get end point... nucleus_tier i
         t = t1 + (t2-t1)/2
         s$ = Get label of interval... pointer_tier i
         pj = 's$'
         if (pj <= nrof_nuclei_analysed)
           select nucldatID
           value = Get value... pj property
           yST =  hertzToSemitones(value) - hertzToSemitones(1)
	   'win$'Text special... t centre yST bottom Helvetica small_fontsize 0 'value:2'
         endif
      endif
   endfor
endproc


procedure gr_plot_feature gridID table col x1 x2 x$ y text$ color$
# For each syllable, draws text at Y-position, provided feature is true (i.e. >= 0)  
# <col_label>	is the label of a column, i.e. some variable/feature/attribute.
# <y>		y value : percentage of Y range
# <x1>...<x2>	time range
# <x$>		position text relative to nucleus : Centre, Right, Left of nucleus
   select table
   bottom = -nrofplottedtiers*100/4
   'win$'Axes... x1 x2 bottom 100
   'win$''color$'
   'win$'Line width... 1
   call interval_from_time gridID nucleus_tier x1 first_interval
   call interval_from_time gridID nucleus_tier x2 last_interval
   for interv from first_interval to last_interval
      select gridID
      label$ = Get label of interval... nucleus_tier interv
      if (label$ = "a")
         nx1 = Get start point... nucleus_tier interv
         nx2 = Get end point... nucleus_tier interv
         s$ = Get label of interval... pointer_tier interv
	 if (length(s$))
            row = 's$'
            if (row <= nrof_nuclei_analysed)
               select table
               value = Get value... row col
               if (value > 0)			; feature present
                  if (x$ = "Left")			; left of nucleus
                      x_ = nx1
                      halign$ = "Right"		; horizontal alignment is Right (like "Right adjusted")
                  elsif (x$ = "Right")		; left of nucleus
                      x_ = nx2
                      halign$ = "Left"
                  else
                      x_ = nx1 + (nx2-nx1)/2	; midtime
                      halign$ = "Centre"
                  endif
                  if (x_ >= x1 and x_ <= x2)
                      'win$'Text special... x_ 'halign$' y Bottom Helvetica fontsize 0 'text$'
                  endif
               endif
            endif
         endif
      endif
   endfor
endproc


procedure gr_viewport_size
# Set size of strip
# Set nrof op strips per page depending on number of tiers in TextGrid plotted
# Viewport position (vx*) and world coordinates (time*, y*)
	vx1 = 0.5			; left side
	vx2 = vx1 + viewport_width	; right side
	vy1 = 0				; top
	npt = max(0, nrofplottedtiers-1)
	if (view < 3) ; compact
	    vy2 = 1.55 + npt * 0.15
	    vyincr = 0.95 + npt * 0.15
	    plotspagetiers$ = "0:10, 1:10, 2:9, 3:8, 4:7, 5:6, 6:5"
	elsif (view < 5 or task == task_pitch_plot or task == task_annotation) ; wide
	    vy2 = 1.8 + npt * 0.2
	    vyincr = 1.3 + npt * 0.2
	    plotspagetiers$ = "0:7, 1:7, 2:6, 3:5, 4:4, 5:4, 6:3"
	else ; large
	    vy2 = 4 + npt * 0.3
	    vyincr = vy2
	    plotspagetiers$ = "0:2, 1:2, 2:2, 3:2, 4:2, 5:2, 6:2"
	endif
	plots_per_page = extractNumber (plotspagetiers$, "'nrofplottedtiers':")
	'win$'Select outer viewport... vx1 vx2 vy1 vy2
endproc


procedure gr_first_viewport_of_page
	call gr_viewport_size
;printline vx1='vx1' vx2='vx2' vy1='vy1' vy2='vy2'
	Line width... 1
    # number of plots; is used to decide when to start a new page
	nrof_plots = 1
	Erase all
    # area of page used by drawings; for Postscript bounding box
	bb_x1 = vx1
	bb_x2 = vx2
	bb_y1 = vy1
	bb_y2 = vy2
endproc


procedure gr_next_viewport
	vy1 += vyincr
	vy2 += vyincr
	Viewport... vx1 vx2 vy1 vy2
	nrof_plots += 1
    # update Postscript bounding box
	bb_y2 = vy2
endproc


procedure gr_write_prosogram
# Write EPS/EMF/PDF/JPG file, after adjusting bounding box and after constructing filename.
    # Praat draws figures inside viewport, leaving margins for garnish.
    # Modify BoundingBox to decrease margins.
    # They will be reset by next call to first_viewport_of_page.
	if (view <= 2)
	   bb_y1 += 0.3
	   bb_x1 += 0.5
	else
	   bb_y1 += 0.15
	   bb_x1 += 0.25
	endif
	bb_y2 -= 0.3
	bb_x2 -= 0.5
	Viewport... bb_x1 bb_x2 bb_y1 bb_y2

    # Construct filename for output file
	padding$ = ""
	if (file_ctr <= 9)
	   padding$ = "00"
	elsif (file_ctr <= 99)
	   padding$ = "0"
	endif
	output_file$ = output_fname$ + padding$ + "'file_ctr'"
	if (index(output_format$,"EPS") or (index(output_format$,"PDF") and windows))
;printline WRITING 'output_file$'=<'output_file$'> epsfile=<'epsfile$'>
	   epsfile$ = output_file$ + ".eps"
	   Write to EPS file... 'epsfile$'
	endif
	if (index(output_format$,"EMF") > 0 and windows)
	   emffile$ = output_file$ + ".emf"
	   Write to Windows metafile... 'emffile$'
	endif
	if (index(output_format$,"PDF"))
	   if (macintosh)
              outfile$ = output_file$ + ".pdf"
	      Save as PDF file... 'outfile$'
           elsif (windows)
              res = 300	; resolution in dpi
	      command$ = path_ghostscript$ + " -dNOPAUSE -dBATCH -dQUIET -sDEVICE=pdfwrite -r'res' -sOutputFile=""'output_file$'.pdf"" 'epsfile$'"
	      system 'command$'
           endif
 	endif
	if (index(output_format$,"JPG") > 0 and windows)
           res = 300	; resolution in dpi
           if (index(output_format$,"600") > 0)
              res = 600
           endif
           command$ = path_ghostscript$ + " -dNOPAUSE -dBATCH -dQUIET -sDEVICE=jpeg -sEPSCrop -r'res' -sOutputFile=""'output_file$'.jpg"" 'epsfile$'"
	   system 'command$'
	endif
	file_ctr += 1
endproc


;procedure multipage_pdf
;   ; pdf_in$ = replace_regex$ (input_files$, "\.eps", "\.pdf", 1)
;   pdf_in$ = replace_regex$ (input_files$, "\.eps", "\.pdf", 1)
;   pdf_out$ = replace_regex$ (input_files$, "[0-9\*]*\.eps", "\.pdf", 1)
;   pdf_files$ = ""
;   if (index (output_format$, "multipage"))
;      ; use wildcard expansion by pdftk in order to avoid command line buffer overflow
;      command$ = "pdftk 'pdf_in$' cat output 'pdf_out$'"
;      system 'command$'
;   endif
;endproc


procedure gr_write_all_prosograms anal_t1 anal_t2 timeincr
   demowin = 0		; drawing in Picture window
   win$ = ""
   grid_in_prosogram = 1
 # Viewport world coordinates
   time1 = anal_t1
   repeat		; for each prosogram strip
      time2 = time1 + timeincr
;call msg gr_write_all: loop time1='time1:4' time2='time2:4'
      if (auto_pitchrange)  ; LOCAL automatic pitch range selection
         ; call autorange stylSTID nucleiID time1 time2 1
;call msg gr_write_all: before speaker_autorange
         call speaker_autorange time1 time2
         ySTmax = ymax
         ySTmin = ymin
      endif
;printline gr_write_all_prosograms A time1='time1:3' nrof_plots='nrof_plots' iFile='iFile'
;printline gr_write_all_prosograms A time1='time1:3' ySTmin='ySTmin:1' ySTmax='ySTmax:1'
;call msg gr_write_all: before display
      call gr_display_prosogram time1 time2 ySTmin ySTmax grid_in_prosogram
;printline gr_write_all_prosograms B time1='time1:3' time2='time2:3' anal_t2='anal_t2:3' nrof_plots='nrof_plots' iFile='iFile' plotsperpage='plots_per_page'
    # prepare for next window pane
      if (nrof_plots >= plots_per_page 
	    ... or (nrofFiles == 1 and time2 >= anal_t2)
	    ... or (single_fname_graphics_output = 0 and time2 >= anal_t2) 
	    ... or (outputmode$ = "One") )
;printline gr_write_all_prosograms B time1='time1:3' nrof_plots='nrof_plots' iFile='iFile'
		call gr_write_prosogram
		call gr_first_viewport_of_page
      elsif (time2 < anal_t2 or iFile < nrofFiles)
		call gr_next_viewport
      endif
      time1 += timeincr
;call msg gr_write_all: before until time1='time1:4' anal_t2='anal_t2:4'
   until (time1 >= anal_t2)
endproc


procedure gr_write_all_annotation anal_t1 anal_t2 timeincr
   demowin = 0		; drawing in Picture window
   grid_in_prosogram = 1
   time1 = anal_t1
   repeat		; for each prosogram strip
      time2 = time1 + timeincr
      call gr_display_prosogram time1 time2 1 100 grid_in_prosogram
      if (nrof_plots >= plots_per_page 
	 ... or (nrofFiles == 1 and time2 >= anal_t2)
	 ... or (outputmode$ = "One") )		; prepare for next window pane
         call gr_write_prosogram
         call gr_first_viewport_of_page
      elsif (time2 < anal_t2 or iFile < nrofFiles)
         call gr_next_viewport
      endif
      time1 += timeincr
    until (time1 >= anal_t2)
endproc

