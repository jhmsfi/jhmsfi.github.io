# Bulletin Board System for the World Wide Web
# Created by Matt Wright
# Version 1.0
# Created On: 6/9/95    Last Modified On: 6/23/95
# Contact Me Here:      mattw@alpha.pr1.k12.co.us
#                       http://alpha.pr1.k12.co.us/~mattw/home.html

This Bulletin Board System for the WWW was created by me, so that the users of 
the system I am on would have a way to communicate with everyone else, without 
having to mail everyone on the system.  It also provides an easy way to post 
replies.  This README will be very lengthy due to the complexity of the 
system.  I suggest you read it however as you will have to read some of it to 
fully understand the way it works and to be able to modify your script in the 
manner you like. Although I will be willing to help you install this, I would 
like you to have at least read this whole document, as it should answer many 
questions, and I didn't write it just cause I was bored one day (or did I?)  :)
----------------------------------------------------------------------

The Bulletin Board System for the WWW comes was a tar file with 3 perl 
scripts, an FAQ, a html page, a short log file, and the messages directory.  
You can also download the files separately.  These files can be found here:
http://alpha.pr1.k12.co.us/~mattw/scripts.html

FILES INCLUDED:
        msgs.pl - The Main Perl Script that adds new messages
        followup.pl - The Perl Script that generates a followup form
        postfp.pl - The Perl Script That posts the followup message
        README - This file (Installation Instructions)
        msgs.html - The Main Message board HTML File.
        messages/ - The directory that messages will be stored in
        faq.html - A small FAQ you can display to your users
        msgslog.html - The short log file

REQUIREMENTS:
        Perl - I have version 5.0, but it should work on earlier
                versions also.
        Machine - Tested and created under a Dec Alpha running OSF/1.
                  I assume as long as you have unix you are ok, I would
                  love to hear what other systems this has worked on.
        Access on your server - This script can be run by any user as
                  long as it is placed in the cgi-bin of your server or
                  has been given the proper file extension, if one has
                  been designated by your system administrator.

SUGGESTED SETUP: (~mydir = my real directory + the WWW directory,
                  usually called public_html)
        ~mydir/msgs.html
        ~mydir/messages/
        ~mydir/faq.html
        ~mydir/msgslog.html
        ~mydir/README
        /cgi-bin/msgs.pl*
        /cgi-bin/followup.pl*
        /cgi-bin/postfp.pl*
                * - Indicates they must be located there
______________________________________________________________________

Description of Files and What to do with them:

MSGS.PL -
        This is the main perl script that takes the information from the form 
on msgs.html, processes it, adds the entry to msgs.html and create a file for 
the message.  There are several variables and options that you will have to 
define.  Below I will list them and what you should do with each one:

        # Define Variables
                $filename = "";
                        This is what the future filename of all new
                        messages posted will be.  You must correct the
                        directory, but I suggest leaving the portion
                        /msgs/messages/msgs$$.html in there.  You must
                        have the $$ somewhere in the filename, as this
                        adds the PID (process id) to the filename and 
                        makes each file unique.  This path is not a
                        url, it is the system path to the filename.
                $logfile = "";
                        This defines the real path to the log file.
                        It is not necessary if you turn off the uselog
                        option.  This is not the url, simply the
                        system path to the logfile.
                $mesgpage = "";
                        The real system path to the msgs.html file.
                        This is necessary for the editing and addition
                        of new entries to the file.
                $mesgpageurl = "";
                        The url of your msgs.html file.
                $filenameurl =  "";
                        The url of your $filename.  This must also
                        contain the $$ as it will define the PID.
                $followup = "";
                        URL of the followup.pl script.

        # Choose Options
                $uselog = ""; # 1 = YES; 0 = NO
                        The uselog option will allow you to choose
                        whether to use the short log that comes with
                        the scripts or not to.  I suggest using it,
                        since it will provide you with the remote_host
                        of all postings.  1 will turn on the option
                        and begin to use the log, and 0 will turn the
                       log off.

THIS FILE must be placed in the cgi-bin of your server and chmoded to 755 
(chmod u+rwx; chmod a+rx).
_______________

FOLLOWUP.PL -
        This script will take the information from an already posted message, 
process it, and turn it into a form on which the user who is following up can 
then write his own comment.  The form that comes to followup.pl is entirely in 
hidden fields which are created by msgs.pl. When the user clicks on the link: 
Post Follow-Up Message it then gives him this form.  There are also a couple 
of variables that need to be filled out before it will work correctly:

        # Define Variables
                $mesgpageurl = "";
                        The same as $mesgpageurl in the msgs.pl script
                $followup = "";
                        The URL of the postfp.pl script.

THIS FILE must be placed in the cgi-bin of your server and chmoded to 755 
(chmod u+rwx; chmod a+rx).
_______________

POSTFP.PL -
        This is the script that takes the form generated by followup.pl and 
turns it into the message, which is ten posted to its own html page and a link 
is added to the message it is a followup on.  This file also includes several 
variables as well as options.
        
        # Define Variables
                $filename = "";
                        The same as $filename in the msgs.pl script
                $mesgpageurl = "";
                        The same as $mesgpageurl in the msgs.pl script
                $filenameurl = "";
                        The same as $filenameurl in the msgs.pl script
                $logfile = "";
                        The same as $logfile in the msgs.pl script

        # Choose Options
                $uselog =""; # 1 = YES; 0 = NO
                        The same as $uselog in the msgs.pl script

THIS FILE must be placed in the cgi-bin of your server and chmoded to 755 
(chmod u+rwx; chmod a+rx).
_______________

Take a big sigh.  If everything works here you are past the hard part!
_______________

MSGS.HTML -
        This page might need a significant amount of editing.  This is the 
html page that the users will first see.  It will contain the headings of the 
postings, as well as a form for users so they can post as well.  This file 
might take a significant amount of editing.  The first things you will want to 
change is the title and head of the script, to fit whatever you are using this 
for.  You might want to also change the intro paragraph, but I suggest keeping 
the FAQ available for people.  Keep the <META> tag in there and also leave all 
of the form fields alone.  By changing the names of them you can mess up 
everything.  You will need to change the action of the form on this page to 
point to your msgs.pl script.  You can also change the link at the bottom to 
point to your email address. (Although I wouldn't mind you leaving my name in 
there somewhere!).  Make sure that you put this file in a directory with rw 
access and give this file rw access  You can use chmod a+rwx or chmod 777 for 
this.  This makes it world writable, so if you have people who like to abuse 
things on your system, you might have trouble.
________________

MSGSLOG.HTML -
        This file is optional.  You will only need it if you set the $uselog 
option to 1.  You shouldn't have top change much of anything about this, as you 
will be the only one seeing it.  If you use this file you will need to make it 
world writable/readable, etc... (explained on last file description).
________________

README - 
        The one file you don't have to do anything with except READ!!!
________________

FAQ.HTML -
        This file does not need anything done to it either.  Just make sure 
you set the permissions so everyone can read it.  I suggest implementing it on 
the page as it will answer some of the users questions (Hopefully).  This is 
not an FAQ for how to set this program up.  That will be attached at the 
bottom of the README!
________________

MESSAGES/ - 
        This is the directory in which all of the users' messages will be 
stored, should you arrange it that way in the script.  You need to give this 
all permissions also. (chmod 777; chmod a+rwx).
________________

WOW!  We are done with the files!  Say YAY and Pray that they work.
____________________________________________________________________

Frequently Asked Questions about this script and others that I have created:

1) What is chmod and how do I use it?
2) Why isn't it working? (Please read if you are about to ask this)
3) What is a cgi-bin?

Answers:

1. chmod is a unix program and it changes the security settings on files.  
There are various categories.  To find out more about this command type: man 
chmod.

2. There could be many reasons why the script is not working.  Before you mail 
me with your questions, please check the following:
        a. Do you have all the permissions set correctly?  - This is
           the most common problem, and very frustrating.
        b. Check the error_log of your server.  Often helpful.
        c. If all else fails mail me and I will try to help.  If you
           are going to mail me for help setting this up I ask that
           you do the following, not because I am mean, but rather
           because I don't have just tons of time on my hands, and I
           am not getting paid for tech support! :)
                1) Check your error_log, copy the message that was
                   reported and send it to me.
                2) Give me as many details to the problem as you can

3. A cgi-bin is a special directory designated by the srm.conf file in the 
httpd directory of your server.  Files must be placed here to be executable 
through the WWW.  If you get an error saying that you are unable to perform 
this function in a non-script area at this time, this is your problem.  Check 
with your sysadmin about getting him to let you put your files in there, or see 
if the has added a type such as all .cgi files execute.
_______________

I hope that you enjoy this script.  I would love to hear comments and 
suggestions from you.  All you have to do to register this program is send me 
the URL of where you are using it.  By doing this I will be able to:
                1) Ask you what you would like to improve about it
                2) Add you to my list of places where people can go to
                   see the script in action.
                3) Send you notices about upgrades that you may be
                   interested in.

If you have an idea/comment/suggestion/improvement please let me know. It 
would be nice if you would leave my name and a pointer to my script archive 
somewhere in the script or on the message page, but it is not necessary.  Use 
this script freely, and modify it however you want, but I make no guarantees 
that it is bug free or completely secure.  I only did my best!
_____________________________________________________________________

Version History:

Version 1.0 - Developed between 6/9/95 and 6/24/95

Plans for Version 1.1:
* Much better log format, the ability to allow you to choose between html 3.0 
  table format and the norm that is in place now.
* When users are returned to an error message they can fill in the rest of the 
  blanks with their previous information carried over.
* Anything else that gets suggested to me!

_____________________________________________________________________
Matt Wright - mattw@alpha.pr1.k12.co.us

