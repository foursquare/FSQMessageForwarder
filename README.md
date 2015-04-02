FSQMessageForwarder
===============

An Obj-C message forwarder class, for when you don't have access to the source of the sending object.

Overview
========

The delegate pattern is very common in many Obj-C libraries, such as UIKit. However sometimes you want the ability to have more than one object receive delegate callbacks. FSQMessageForwarder acts as proxy delegate object, forwarding messages it receives to other objects.

Note: A test project is included but it is used for build testing only - an example application is currently not included in this repository.

Setup
=====

FSQMessageForwarder is only two files with no external dependencies, so it should be quick and easy to add to your app. Simply download the files and copy them into your project. Alternatively you can use CocoaPods or git submodules to link your repo against this one for easy updating when future versions are released.

Using Message Forwarder
=======================

There are two different flavors of message forwarder included. One manages its own array of weak references to child objects. The other uses an enumerator to manage its children which is provided to it by a delegate object that you set. 

Either way, using the forwarder is simple. Just instantiate and retain the type of forwarder you want to use and setup its list of child objects. Usually you will then set the forwarder as the delegate of some other class (such as UITableView). The forwarder will forward any messages it does not itself implement to all of its children in order.

Calls to conformsToProtocol:, respondsToSelector:, and methodSignatureForSelector: will work as expected (eg. the forwarder conforms to a protocol if any of its children do, etc.).

If you yourself are writing the sending object, it is generally better to just write your code in such a way that it supports multiple delegates. FSQMessageForwarder is intended to be a workaround for 3rd-party classes that you do not have direct control over (such as those in UIKit)

Return Values
=============

If a forwarded message has a return value, the return value of the first child to respond to the message will be used. If a later child would like its return value to be used instead, it can implement messageForwarder:shouldUseResponseForInvocation: to override this behavior.

Contributors
============

FSQMessageForwarder was initially developed by Foursquare Labs for internal use. It was originally written and is currently maintained by Brian Dorfman ([@bdorfman](https://twitter.com/bdorfman)).
