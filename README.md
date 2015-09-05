# hugomac

Hugomac is an osx menubar app to publish your blog directly to Amazon S3. It uses the wonderful [Hugo](https://github.com/spf13/hugo) static site generator to create your blog without having to touch a command line.

I wanted to keep a directory of (somewhat) publisher-agnostic markdown files synced across all my machines using existing tools (dropbox, google drive, icloud, etc) with all the convenience of generating a static site in seconds on any of my local computers and the simplicity of S3 website hosting which costs next to nothing and doesn't require any maintenence.

## setup

* create an S3 bucket and enable it for website hosting
* get some S3 credentials that have write access to that bucket
* configure hugomac with the bucket name and credentials
