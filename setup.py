#!/usr/bin/env python

from distutils.core import setup
from os.path import join

scripts = [join("install", "fenics-install.sh"),
           join("install", "fenics-install-component.sh"),
           join("install", "fenics-install-all.sh"),
           join("install", "fenics-clone-all.sh"),
           join("install", "fenics-pip.sh"),
           join("release", "fenics-release.sh")]

setup(name = "fenics-developer-tools",
      version = "1.5",
      description = "FEniCS Developer Tools",
      author = "Anders Logg et al.",
      author_email = "logg@chalmers.se",
      url = "http://www.fenicsproject.org/",
      packages = [],
      scripts = scripts,
      data_files = [])
