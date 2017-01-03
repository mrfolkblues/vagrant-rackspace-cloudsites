# Rackspace Cloud Sites Vagrant Setup

This Vagrantfile and provisioning script will create a virtual machine using [VirtualBox](https://www.virtualbox.org/wiki/Downloads) that is very similar to the configuration of a basic Rackspace Cloud Site. It uses:

- Debian Jessie64
- Apache 2
- MariaDB 10.0
- PHP 5.6.29

There are a few PHP features missing from this setup at the moment. If you were to run `phpinfo();` on both this setup and a real Cloud Site, you'd see the differences. They should be minimal and unobtrusive. For example, this setup is lacking the Zend Guard Loader because installation wasn't simple and it wasn't critical to include at the time I created this.

## IP and Synced Folder

- The machine's IP will be `192.168.33.33`.
- The synced folder for all sites will be `/var/www/vhosts` on the guest machine.

## Installation

### Step 1
Clone this into the same folder where your web projects live. For example, let's say you have the following folder structure:

```
Web
|_  project-1
|_  project-2
|_  wordpress-site
```

You'd run `git clone git@github.com:myusername/vagrant-rackspace-cloudsites.git` in the `Web` folder.

### Step 2
Install the [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest) plugin by typing `vagrant plugin install vagrant-vbguest`. This is important, because it will ensure the **VirtualBox Guest Additions** are installed prior to Vagrant trying to create the synced folders.

### Step 3
Run `vagrant up`. This will probably take a few minutes to do the whole process, but you should only have to do this once. After this, your machine will be ready to use.

## Synced Folder
The folder that is one level up from the Vagrantfile (in the example above, this is the `Web` folder) is a synced folder on the guest machine. As a result, you'll find all of your sites in `/var/www/vhosts`.

The default synced folder also exists, but in this application it's not terribly useful.

## How to Use
It's a bit different than how most Vagrant setups are done. The intent here is to create a single virtual machine that can host all of your sites simultaneously by using virtual hosts. The [vhost](https://gist.github.com/fideloper/2710970#file-vhost-sh) command is included to make virtual host setup easier. SSH into the machine with `vagrant ssh` and set up the virtual hosts, then edit your hosts file to point your custom domain at the virtual machine's IP. Run the server with `vagrant up` and stop it when you're done with `vagrant halt`, but you'll probably *never* want to run `vagrant destroy` after it's set up. Of course, if you know what you're doing, you can reconfigure this a little and use it however you like.

## Example
If your project folder is called **project-1** and you want to access it in your browser at **project-1.dev**, first create the virtual host:

```shell
$ vagrant ssh
vagrant@jessie:~$ sudo vhost -d /var/www/vhosts/project-1 -s project-1.dev
vagrant@jessie:~$ exit
$
```

Then [edit your hosts file](http://www.howtogeek.com/howto/27350/beginner-geek-how-to-edit-your-hosts-file/), adding a line like:
```shell
192.168.33.33 project-1.dev
```

## Optional: Create Aliases
It can be tedious to change into the `vagrant-rackspace-cloudsites` folder every time you want to start the server or ssh into it. The following aliases will allow you to run the usual commands from anywhere. You may need to edit the paths depending on your own folder structure. Add these to your `.bashrc`, `.zshrc`, or other equivalent file.

```
alias vup="(cd ~/Web/vagrant-rackspace-cloudsites && vagrant up)"
alias vstat="(cd ~/Web/vagrant-rackspace-cloudsites && vagrant status)"
alias vhalt="(cd ~/Web/vagrant-rackspace-cloudsites && vagrant halt)"
alias vreload="(cd ~/Web/vagrant-rackspace-cloudsites && vagrant reload)"
alias vprovision="(cd ~/Web/vagrant-rackspace-cloudsites && vagrant provision)"
alias vssh="(cd ~/Web/vagrant-rackspace-cloudsites && vagrant ssh)"
```

## Enjoy!