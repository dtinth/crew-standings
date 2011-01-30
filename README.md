[crew-standings](http://dtinth.github.com/crew-standings)
==============

A simple mashup application which displays the current standings of selected crews in [DJMAX Technika 2: Crew Race](http://djmaxcrew.com/default.html).


Notes
-----

* The list is sorted by __overall rank__ or __crew points__.
* Too big? __Zoom out__ to see all crews!
* Data is [cached](http://www.yqlblog.net/blog/2010/03/12/avoiding-rate-limits-and-getting-banned-in-yql-and-pipes-caching-is-your-friend/) for up to 30 minutes.
* Crew names are case-sensitive.


URL Parameters
--------------

* By appending `?crew=` followed by crew name, that crew is displayed instead of the default list.
* By appending `?` followed by a list name, all crews in the list are displayed instead of the default list.


Adding Your Own List
--------------------

In the [groups](https://github.com/dtinth/crew-standings/tree/gh-pages/groups) folder, you will see `.xml` files.
The filename is the list name (only lowercase characters allowed!), and the XML file contains the list of crews to be shown.
The format is self-explanatory.

To add your own crew list, fork the project and add `.xml` files to the groups folder. Send me a pull request if you want.


Powered By
----------

* [YQL](http://developer.yahoo.com/yql/) for fetching data.
* [jQuery](http://jquery.com/)
* [CoffeeScript](http://jashkenas.github.com/coffee-script/)


Tested Browser
--------------
* Firefox 3.6
* Safari 5
* MobileSafari on iPad (iOS 3.2)
* Internet Explorer 7
* Internet Explorer 6 (tested not to work!)


License
-------
Licensed [CC BY 3.0](http://creativecommons.org/licenses/by/3.0/).
