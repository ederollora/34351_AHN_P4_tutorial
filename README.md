# 34351 Home and access networks

This tutorial is based on the original created by the P4 community.
We thank the developers that have contributed to create this fantastic
tutorial. We will include soon some new exercises too.

**More exercises soon**

## Introduction

Welcome to the P4 Tutorial! We've prepared a set of exercises to help
you get started with P4 programming, organized into several modules:

1. Introduction and Language Basics
* [Basic Forwarding](./exercises/basic)
* [Basic Tunneling](./exercises/basic_tunnel)
* [Calculator](./exercises/calculator)

## Presentation

Additional tutorial slides from the P4 community are available
in the P4_tutorial.pdf in the tutorial directory.

A P4 Cheat Sheet is also available [online](https://drive.google.com/file/d/1Z8woKyElFAOP6bMd8tRa_Q4SA1cd_Uva/view?usp=sharing)
which contains various examples that you can refer to.

## Obtaining required software

**You don't need this as we give you a VM. If you wish to create a VM from scratch for the tests, feel free to check next steps.**

If you are starting this tutorial at one of the proctored tutorial events,
then we've already provided you with a virtual machine that has all of
the required software installed. Ask an instructor for a USB stick with
the VM image.

Otherwise, to complete the exercises, you will need to either build a
virtual machine or install several dependencies.

To build the virtual machine:
- Install [Vagrant](https://vagrantup.com) and [VirtualBox](https://virtualbox.org)
- Clone the repository
- Before proceeding, ensure that your system has at least 25 Gbytes of free disk space, otherwise the installation can fail in unpredictable ways.
- `cd vm`
- `vagrant up` - This step typically takes over 1 hour to complete, and requires a reliable Internet connection throughout.
- When the machine reboots, you should have a graphical desktop machine with the required software pre-installed.  There are two user accounts on the VM, `vagrant` (password `vagrant`) and `p4` (password `p4`).  The account `p4` should be logged in when the VM boots up by default, and is the one you are expected to use.

*Note*: Before running the `vagrant up` command, make sure you have enabled virtualization in your environment; otherwise you may get a "VT-x is disabled in the BIOS for both all CPU modes" error. Check [this](https://stackoverflow.com/questions/33304393/vt-x-is-disabled-in-the-bios-for-both-all-cpu-modes-verr-vmx-msr-all-vmx-disabl) for enabling it in virtualbox and/or BIOS for different system configurations.

You will need the script to execute to completion before you can see the `p4` login on your virtual machine's GUI. In some cases, the `vagrant up` command brings up only the default `vagrant` login with the password `vagrant`. Dependencies may or may not have been installed for you to proceed with running P4 programs. Please refer the [existing issues](https://github.com/p4lang/tutorials/issues) to help fix your problem or create a new one if your specific problem isn't addressed there.

To install dependencies by hand, please reference the [vm](./vm) installation scripts.
They contain the dependencies, versions, and installation procedure.
You should be able to run them directly on an Ubuntu 16.04 machine:
- `sudo ./root-bootstrap.sh`
- `sudo ./user-bootstrap.sh`
