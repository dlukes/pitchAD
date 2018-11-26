# prosogram.praat
# For documentation see http://bach.arts.kuleuven.be/pmertens/prosogram/
# Requires Praat 5.1.16 or higher.

# Author: Piet Mertens
# Last modification: 2012-03-27
# Copyright 2003-2012 Piet Mertens

form Prosogram 2.9f (Mar 27, 2012)
	optionmenu Task 1
		option Prosogram and prosodic profile
		option Interactive prosogram
		option Prosodic profile only (no drawing)
		option Recalculate pitch for entire sound file
;		option Recalculate loudness for entire sound file
		option Make automatic segmentation into syllables and save
		option Plot pitch in semitones, with annotation. No stylization.
;		option Draw annotation only. No stylization.
;		option Prosodic boundary detection
;		option Prosodic contour annotation
;		option Script
   comment Input sound files: (leave empty for interactive file selection)
	text Input_files C:/corpus/*.wav
   comment Analysis parameters:
	real left_Time_range_(s) 0.0
	real right_Time_range_(s) 0.0 (=all)
	real left_F0_detection_range_(Hz) 60 (=default)
	real right_F0_detection_range_(Hz) 450 (=default)
	optionmenu Parameter_calculation: 1
		option Full (saved in file)
		option Partial (not saved in file)
	optionmenu Frame_period_(s): 1
		option 0.005
		option 0.01
	optionmenu Segmentation_method 1
		option Automatic: acoustic syllables
		option Nuclei in vowels in tier "phon..." or tier 1
		option Nuclei in rime from "syll..." and vowels in "phon..."
		option Nuclei in syllables in "syll..." and vowels in "phon..."
		option Nuclei in syllables in "syll..." and local peak
;		option Automatic: peak of loudness (obsolete)
;		option Automatic: peak of intensity of BP-filtered signal (obsolete)
		option Using external segmentation in tier "segm..."
;		option Automatic: acoustic syllables (using loudness)
	optionmenu Thresholds: 3
		option G=0.16/T^2, DG=20, dmin=0.035
		option G=0.24/T^2, DG=20, dmin=0.035
		option G=0.32/T^2, DG=20, dmin=0.035
		option G=0.32/T^2, DG=30, dmin=0.050
		option G=0.24-0.32/T^2 (adaptive), DG=30, dmin=0.050
		option G=0.16-0.32/T^2 (adaptive), DG=30, dmin=0.050
	boolean Save_intermediate_data 0
   comment Plotting options:
	optionmenu View: 4
		option 1: Compact
		option 2: Compact rich
		option 3: Wide
		option 4: Wide rich
		option 4: Wide rich, with values pitch targets
		option 4: Wide rich, with pitch range
;		option 5: Large
;		option 6: Large rich
	positive Time_interval_per_strip_(s) 3.0
        sentence Tiers_to_show_(*convert_to_IPA) *1, 2, 3
	real left_Pitch_range_(ST) 0 (=autorange)
	real right_Pitch_range_(ST) 100
;	optionmenu Output_mode: 1
;		option Fill page with strips
;		option One strip per file
	optionmenu Output_format: 1
		option EPS (Encapsulated Postscript)
		option EMF (Windows Enhanced Metafile)
		option EMF and EPS
		option PDF
		option EPS and JPG 300 dpi (Windows, Ghostscript must be installed)
		option EPS and JPG 600 dpi (Windows, Ghostscript must be installed)
   comment Output path and filename for graphics files (number and extension added automatically) :
	text Output_filename <input_directory>/<basename>_
endform

clearinfo

include prosomain.praat
include prosoplot.praat
include segment.praat
include stylize.praat
include util.praat


   version$ = "Prosogram v2.9"
# ------------- Special options  --------------
   # Font used in plot
      font_family$ = "Helvetica"	; else use "Times"
   # width of viewport used for prosogram (inches) 
      viewport_width = 7.5
   # Clip stylisation to Y range 
      clip_to_Y_range = 0
   # Use greyscale instead of colors
      greyscale = 0

   call main

   exit
