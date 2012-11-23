var tools = require('jake-tools');
var path = require("path");
var fs = require("fs");

task('default', function(){
  jake.Task['coverage'].invoke();

});

desc('Release build');
task('release', function(){
  var dir = "out/release";
  tools.print("Clean Build Directory");
  tools.treeDelete(dir);
  tools.print("Copy CoffeeScripts");
  tools.listCopy(dir, './lib/**');
  tools.print("Compile CoffeeScripts");
  tools.coffee(dir + '/**/*.coffee');
  tools.print("Delete CoffeeScripts");
  tools.listDelete(dir + '/**/*.coffee');
});

desc('Run unittest');
task('unit', function(){
  tools.mocha(["tests/test-*.js", "tests/**/test-*.coffee"]);
});

desc('Test build');
task('coverage', function(){
  var dir = __dirname + "/out/test";
  var report_html= "coverage.html";
  tools.print("Clean Build Directory");
  tools.treeDelete(dir);
  tools.print("Copy CoffeeScripts");
  tools.listCopy(dir, ['lib/**', 'tests/**']);
  tools.print("Compile CoffeeScripts");
  tools.coffee(dir + '/**/*.coffee');
  tools.listDelete(dir + '/**/*.coffee');
  tools.print("Run Test");
  tools.coverage(dir + "/lib", dir + "/tests/**/test-*.js", [], function(code, json){
    tools.testReport('Event Pipe', json, report_html);
    tools.testResult(json);
    tools.print("Test Report");
    console.log('html report saved on "' + report_html + '"');
  });
});

desc("Build clean");
task('clean', function(){
  var dir = "out";
  tools.print("Clean Build Directory");
  tools.treeDelete(dir);
});
