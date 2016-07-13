var gulp = require('gulp');
const del = require('del');
var git = require('gulp-git');
var config = require('config');
var ftp = require( 'vinyl-ftp' );
const zip = require('gulp-zip');
var request = require('request');


var remotePath = '/dev2/';

var conn = ftp.create( {
    host: config.get('ftp.host'),
    port: config.get('ftp.port'),
    user: config.get('ftp.username'),
    password: config.get('ftp.password'),
    parallel: 5
} );


gulp.task('clean', function() {
	return del(['working/']);
});







gulp.task('clone-html', ['clean'], function(cb) {
	var stream = git.clone('https://github.com/COCAFoundation/public_html.git', {args: './working/public_html'}, function (err) {
		if (err){throw err;}else{cb();}
	 });
	return stream; // return the stream as the completion hint
});






gulp.task('clone-template', ['clean'], function(cb) {
	var stream = git.clone('https://github.com/COCAFoundation/coca_template.git', {args: './working/public_html/templates/coca'}, function (err) {
		if (err){throw err;}else{cb();}
	 });
	return stream; // return the stream as the completion hint
});





gulp.task('zip', ['build'], function(){
	var stream = gulp.src('working/public_html/**')
		.pipe(zip('public_html.zip'))
		.pipe(gulp.dest('working/'));
	return stream; // return the stream as the completion hint
});

gulp.task('build', ['clone-html','clone-template'], function(cb){
	gulp.src('./explode.php').pipe(gulp.dest('./working'));
	cb();
});









gulp.task('transfer', ['build','zip'], function() {
	console.log("Tranferring Files")

	var globs = [
	    'working/explode.php',
	    'working/public_html.zip'
	];  


	return gulp.src( globs, { base: './working/', buffer: false } )
		.pipe( conn.newer( remotePath ) ) // only upload newer files 
		.pipe( conn.dest( remotePath ) )

});



/*
* Delete .htaccess removes the htaccess file which would otherwise block us from running the explode php script
*/
gulp.task('delete-htaccess', ['transfer'],function() {
	return conn.delete('/dev2/.htaccess', function () {});
});


/*
* Run explode script
*/
gulp.task('explode', ['delete-htaccess'],function() {
	request('http://dev2.childrenofcentralasia.org/explode.php', function (error, response, body) {
	  if (!error && response.statusCode == 200) {
	    console.log(body) // Show the HTML for the Google homepage. 
	  }
	})
});




gulp.task('default', ['build', 'zip', 'transfer', 'delete-htaccess', 'explode', ],function() {
	//gulp.src('../coca_template/*').pipe(gulp.dest('./working/coca_template'));
	//gulp.src('../public_html/*').pipe(gulp.dest('./working/public_html'));
	//gulp.src('../coca_template/*').pipe(gulp.dest('./working/public_html/templates/coca'));
	//console.log("I am Gulping bitches!!!!")
});
