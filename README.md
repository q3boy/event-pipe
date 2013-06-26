# EventPipe

![travis build info](https://api.travis-ci.org/q3boy/event-pipe.png)

An simple tool to code with event like a pipe.


## Sequence

```javascript
var ep = require('event-pipe');
ep(function(url){ // request an url
	request(url, this)
}, function(err, body){ // request done, write file
	if (err) {
		throw err;
	}
	var file = __dirname + '/google.html';
	fs.writeFile(file, body, this);
}, function(err){ // write file done
	if (err) {
		throw err;
	}
	console.log('done');
}).run('http://www.google.com/') // start pipe
```

```javascript
var ep = require('event-pipe');
var p = ep();
p.seq(step1, step2, step3).seq(step4).run(args)
```

## Parallel
```javascript
var ep = require('event-pipe');
ep.on('drain', function(){
	console.log('all done');
})
ep([function(){
	fs.writeFile('a.file', 'somedata', this);
}, function(){
	fs.writeFile('b.file', 'somedata', this);
}, function(){
	fs.writeFile('c.file', 'somedata', this);
}]).run();
```

```javascript
var ep = require('event-pipe');
var p = ep();
p.par(step1_action1, step1_action2, step1_action3).par(step2_action1, step2_action2).run(args)
```

## Mixed

```javascript
var ep = require('event-pipe');
ep(function(url){ // request an url
	request(url, this)
}, [ // request done, parallel write file
	function(err, body){ // file1
		if (err) {
			throw err;
		}
		var file = __dirname + '/google1.html';
		fs.writeFile(file, body, this);
	},
	function(err, body){ // file2
		if (err) {
			throw err;
		}
		var file = __dirname + '/google2.html';
		fs.writeFile(file, body, this);
	},
], function(err){ // write file done
	console.log('all done');
}).run('http://www.google.com/') // start pipe
```

```javascript
var ep = require('event-pipe');
var p = ep();
p.add(step1, [step2_action1, step2_action2], step3).run(args)
```

## Lazy mode

```javascript
var ep = require('event-pipe');
var e = ep().on('error', function(err){
	console.error('got error:', err.stack);
}).lazy(function(url){ // request an url
	request(url, this)
}).lazy([
	function(body){ // file1
		var file = __dirname + '/google1.html';
		fs.writeFile(file, body, this);
	},
	function(body){ // file2
		var file = __dirname + '/google2.html';
		fs.writeFile(file, body, this);
	},
]).lazy(function(){ // write file done
	console.log('all done');
}).run('http://www.google.com/') // start pipe
```

```javascript
var ep = require('event-pipe');
var p = ep();
p.lseq(step1, step2, step3).run(args)
p.lpar(step1, step2, step3).run(args)
```

## stop
```javascript
var ep = require('event-pipe');
var p = ep();
p.add(step1, step2, function(stop){ // step3, step4 will never be run
	if (stop) {
		this.__stop()
	}
},step3, stop4).seq(step4).run(args)
```

```javascript
var ep = require('event-pipe');
var p = ep();
p.add(step1, step2, step3, stop4).seq(step4).run(args).stop() // step2, step3, step4 will never be run


```
## Events
### error
got error when use lazy mode.
### stop
stop start.
### stopped
pipe stopped.
### drain
no more events.
