'use strict'
module.exports = function(grunt) {

    require('load-grunt-tasks')(grunt)
    var target = grunt.option('target') || "";

    grunt.initConfig({
        config: grunt.file.readJSON("package.json"),
        clean: {
            build: ["dist/"]
        },
        coffee: {
            bundle: {
                options: {
                    sourceMap: true,
                },
                files: {
                    'dist/<%= config.name %>.bundle.js' : [target + 'coffee/*.coffee', 'coffee/*.coffee'] // concat then compile into single file
                }
            }
        },
        uglify: {
            options: {
                banner: '/*\n<%= config.name %> - v<%= config.version %> - ' +
                        ' <%= grunt.template.today("dddd, mmmm dS, yyyy, h:MM:ss TT") %> ' + '\n ' + grunt.file.read("copyright.txt") + '\n*/',
                preserveComments: false,
                sourceMap : true,
                sourceMapIn: "dist/<%= config.name %>.bundle.js.map"
            },
            build: {
                src: 'dist/<%= config.name %>.bundle.js',
                dest: 'dist/<%= config.name %>.bundle.min.js'
            }
        },
        copy: {
            bundle: {
                dest: target + 'dist/<%= config.name %>.config',
                src: [target + '<%= config.name %>.config']
            }
        }
    });
    
    grunt.registerTask('bundle', [ 
        'clean:build',
        'coffee',// Compile CoffeeScript files to JavaScript + concat + map
        'uglify',//min + banner + remove comments + map    
        'copyVersion',
        'copy:bundle'
    ]);
    grunt.registerTask('copyVersion' , 'copy version from package.json to sarine.viewer.clarity.config' , function (){
        var packageFile = grunt.file.readJSON(target + 'package.json');
        var configFileName = target + packageFile.name + '.config';
        var copyFile = null;
        if (grunt.file.exists(configFileName))
            copyFile = grunt.file.readJSON(configFileName);
        
        if (copyFile == null)
            copyFile = {};

        copyFile.version = packageFile.version;
        grunt.file.write(configFileName , JSON.stringify(copyFile));
    });
};
