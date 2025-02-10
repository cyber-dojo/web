// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, (which is)
//     app/assets/javascripts,
//     lib/assets/javascripts,
//     vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
// cyber-dojo has some jquery js files for plug-ins in this dir directly.
// It doesn't do a [gem jquery] in the Gemfile.
//
// Some CodeMirror modes (such as the htmlmixed mode) override parts of other modes and must
// be loaded after the those modes. To ensure this happens the modes which are order
// dependent are stored in the codemirror/mode-ordered directory and required individually.
//
//= require ./jquery.min
//= require ./jquery_ujs
//= require ./jquery-ui.min
//= require ./codemirror/lib/codemirror
//= require_tree ./codemirror/mode
//= require_tree ./codemirror/addon
//= require ./codemirror/mode-ordered/htmlmixed/htmlmixed.js
//= require_tree .
