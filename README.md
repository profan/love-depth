love-depth
=================================

Chunk based isometric world library for LÖVE, for those foolish enough to want to try and make their game world happen in three dimensions.

Requirements
------------

* LÖVE 0.9.1

Running the example project

		love src

Downloading the source
------------

Either with git clone as below or by downloading a zipball of the [latest.](https://github.com/Profan/love-depth/archive/master.zip).

		git clone https://github.com/Profan/love-depth.git

Usage
------------

		...

Details
------------
* ...

TODO
------------
- [ ] Let world class take a function to use for creating chunks.
--[ ] Implement virtual paging for loading chunks, right now world size is static.
- [ ] Implement depth sorting to allow for drawing sprites among the isometric blocks.
- [ ] Implement threading for chunk reconstruction (computing what needs to be drawn).
- [ ] Write tests.

Credits
------------
Credits for the libraries which are used in the example!

* Matthias Richter - [HUMP.](https://github.com/vrld/hump)
* Phoenix Enero - [LoveNoise.](https://github.com/icrawler/LoveNoise)
* Robert Blancakert - [cupid.](https://bitbucket.org/basicer/cupid)


License
------------
See attached LICENSE file.
