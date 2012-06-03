# Joconut

Never load a full page on every request again.

# Getting Started
Download the [production version][min] or the [development version][max].

[min]: https://raw.github.com/vdemedes/joconut/master/dist/joconut.min.js
[max]: https://raw.github.com/vdemedes/joconut/master/dist/joconut.js

Include it in your web pages(1kb minified and gzipped):

```html
<script src="joconut.min.js"></script> <!-- you must include jQuery before that -->
```

That's it! Now, all your local links will not cause page refresh. Remote links will work as expected.

# Features

- Lightweight(1kb minified and gzipped)
- Detects and loads scripts and stylesheets from fetched pages, if they do not exist in the current one
- HTML5 History API support with fallback to location.hash

# Tests

You should have **node** to be installed. ```cd test && npm i connect route66 && node server.js```. Navigate to http://localhost:3000 after that and play.

# License

Copyright (c) 2012 Vadim Demedes  
Licensed under the MIT license.