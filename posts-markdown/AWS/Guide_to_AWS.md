# The Idiotproof Guide to Setting Up Your Personal EC2 Instance

## Signing Up With AWS
* Go to the [AWS signup page](https://portal.aws.amazon.com/gp/aws/developer/registration/index.html). Proceed with the signup process. Note that the information necessary to get up and running with an AWS account includes a valid credit card and a valid phone (used for verification). Have these at the ready.

## Launching Your Instance
* After you've received your activation email, head to the [AWS management console](https://console.aws.amazon.com/console/home?#)(this link requires you to be logged in to AWS). Click on the icon labelled 'EC2'.

**TODO[login screen]**

> For those interested, 'EC2' stands for *Elastic Cloud Compute*. The service itself allows users to rent out virtual computers on which they can boot up their own images. Basically, we're booting onto some random CPU in some Amazon-owned datacenter somewhere in America.

* On the next page, hit the big blue 'Launch Instance' button, as seen below.

**TODO[Launch instance]**

* Next, we proceed with the 'Classic Wizard'. It's at this point that we have to select our disk image. Personally, I like using Ubuntu, so the rest of this tutorial will assume that you select *Ubuntu Server 13.04* (64-bit).
* Click-through (accepting the default settings) until you get to the 'Create a Key Pair' tab. You can read more about public/private key pairs [here](http://en.wikipedia.org/wiki/Public-key_cryptography). Basically, Amazon will give you a *your_keyname.pem* file which will allow you to SSH into your server. Name it whatever you want and save it locally.
* Click through and launch your instance.

**TODO[Finish screen]**

* Wait until your instance state goes from *pending* to *active*. For me, that took about 2-3 minutes. When you see something like this, you're golden.

**TODO[good to go]**

## Getting Onto Your Server

## Installing Essential Tools

## Configuring Your Admin

## Smoothing Out The Workflow
