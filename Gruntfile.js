module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    clean: ["static/js/chiscore", "spec/javascript/target"],

    watch: {
      coffee: {
        files: [
          'spec/javascript/chiscore/**/*.coffee',
          'static/coffee/chiscore/**/*.coffee'
        ],
        tasks: 'coffee'
      },

      jst: {
        files: ['static/templates/**/*.ejs'],
        tasks: 'jst'
      }
    },

    jst: {
      chiscore: {
        options: {
          namespace: 'EJS',
          processName: function(name) {
            return name.replace("static/templates/", "").replace(".ejs", "");
          }
        },
        expand: true,
        cwd: 'static/templates',
        src: ['**/*.ejs'],
        ext: '.js',
        dest: 'static/ejs'
      }
    },

    jasmine: {
      chiscore: {
        src: [
          "static/ejs/checkin.ejs",
          "static/js/chiscore/chiscore.js",
          "static/js/chiscore/checkin.js",
          "static/js/chiscore/checkin-collection.js",
          "static/js/chiscore/checkin-view.js",
          "static/js/chiscore/services.js",
          "static/js/chiscore/board-view.js",
          "static/js/chiscore/checkin_board.js",
          "static/js/chiscore/models/checkin.js",
          "static/js/chiscore/active_board.js"
        ],

        options: {
          vendor: [
            "static/js/jquery.min.js",
            "static/js/underscore.min.js",
            "static/js/backbone.min.js",
          ],
          specs: 'spec/javascript/target/**/*.js',
          helpers: [
            'spec/javascript/support/jasmine-jquery.js',
            'spec/javascript/support/jasmine-fixture.js'
          ]
        }
      }
    },

    coffee: {
      specs: {
        expand: true,
        cwd:  'spec/javascript/chiscore',
        src:  ['**/*.coffee'],
        ext:  '.js',
        dest: 'spec/javascript/target'
      },

      sources: {
        expand: true,
        cwd:  'static/coffee/chiscore',
        src:  ['**/*.coffee'],
        ext:  '.js',
        dest: 'static/js/chiscore'
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-jasmine');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-jst');

  grunt.registerTask('spec', ['clean', 'coffee', 'jst', 'jasmine']);
  grunt.registerTask('build', ['clean', 'coffee', 'jst']);
  grunt.registerTask('default', ['spec']);
};
