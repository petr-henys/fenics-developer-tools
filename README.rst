======================
FEniCS Developer Tools
======================

This repository contains various tools,
including scripts for building, installation, and release of the
various FEniCS software components.


FEniCS Install (fenics-install.sh)
==================================

FEniCS Install is a simple script for easy installation of FEniCS
via HashDist. To install, simply run the script ``fenics-install.sh``.

This may be done via the following command(s)::

  wget -O - http://fenicsproject.org/fenics-install.sh | bash

Or if :code:`wget` is not available, use::

  curl -s http://fenicsproject.org/fenics-install.sh | bash

The script will show a menu where you can choose whether to install the
development version of FEniCS, the current stable version, or only the
dependencies. Setting the environment variable
``FENICS_INSTALL_BUILD_TYPE`` to either 0 (development), 1 (stable), or
2 (dependencies only) will not show this menu.


FEniCS Developer Install
========================

For developers, two additional scripts are provided:

* ``fenics-install-component.sh``
* ``fenics-install-all.sh``

The script ``fenics-install-component.sh`` configures, builds and installs
a given FEniCS component from the current directory.

The script ``fenics-install-all.sh`` first calls ``fenics-install.sh``
to configure, build and install all FEniCS dependencies (using
HashDist). It then proceeds to "manually" build all FEniCS components in
a structured way that helps developers quickly set up and maintain a
working FEniCS developer environment.


Requirements
============

Requirements for Linux (Ubuntu package name in parentheses):

* The Python 2.7 development files (``python-dev``)
* The Git version control system (``git``)
* A C compiler and a C++ compiler with C++11 support
  (``build-essential``)
* A Fortran compiler (``gfortran``)
* The OpenGL development files (``freeglut3-dev``)

Requirements for OS X:

* The latest version of Xcode `from the Apple developer website
  <https://developer.apple.com/downloads/index.action>`__ or get it
  `using the Mac App Store
  <http://itunes.apple.com/us/app/xcode/id497799835>`__
* The Xcode Command Line Developer Tools (run ``xcode-select --install`` in
  a terminal after installing Xcode)
* The Git version control system


License
=======

FEniCS Developer Tools is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

FEniCS Developer Tools is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with FEniCS Developer Tools. If not, see <http://www.gnu.org/licenses/>.

(This license is just for compatibility with other FEniCS packages,
and these small scripts might just as well have been placed in the
public domain.)


Contact
=======

For comments and requests, send an email to the FEniCS mailing list:

  fenics-dev@googlegroups.com


Contributors
============

  Anders Logg <logg@chalmers.se>
  Johannes Ring <johannr@simula.no>
  Martin Sandve Aln�s <martinal@simula.no>