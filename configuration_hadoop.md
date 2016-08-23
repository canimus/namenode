## Hadoop Daemon - Reverse Engineer Setup
---------------------------------------------

### Unlearn the Classic Wizard
Traditionally a mechanism to understand the flow to complete an installation or configuration of a technology shows the path of the successful steps. Unfortunately for many of us, that have been around in this field of technology, we know that things not always go according to plan. In fact, in many cases, we know the probability for things off hand, is indirectly proportional to the amount of experience or knowledge we have on the field. But, as tough as it can gets, nothing beats that comfortable feeling when reaching that last enter, and seeing an entire journey of setup reaching the `OK` lighted in &#x1F49A; green and no exceptions or errors thrown or visual through the user interface.

Now, based on this approach, I decided to start a naive journey of configuration of a Hadoop Cluster, for training purposes and as an induction material for our new employees. In this particular scenario as opposed to showing what is the right thing to do, we go through each of the steps to setup a cluster, and capturing all the errors and steps that will allow us to navigate through the flow followed by the provided launch daemons in the Apache Hadoop distribution to finally being able to put a distributed cluster to work.

### Seting up the Environment

The first step in configuring our environment will be launching a Virtual Machine that contains the necessary environment for us to run every single command in this notebook.

>Don't worry we will start from scratch so you can reproduce every single step as explained in this tutorial, minimizing the changes of failure. And also, considering that you don't have commodity hardware at your disposal with 64GB of memory or plenty of computing power to play with.

#### Hard Pre-Requisites

Unfortunately because setting up the steps for each platform will be quite challenging for a single notebook, the idea is to count with at least the following technologies available in your environment:

1. [Virtual Box by Oracle](https://www.virtualbox.org/wiki/Downloads)
2. [Vagrant by Hashicorp](https://www.vagrantup.com/downloads.html)

Installation process is straight forward and will not involve rocket science to get it to work, that is, in fact, the traditional wizard composed by the **Next** -> **Next** -> **Next** -> **Finish** approach.

### Vagrant Setup

Ok, let's assume that you reach this far, and that your system is ready to launch virtual machines, perhaps you didn't have to struggle like me, setting up the BIOS on your fancy new laptop and enabling the virtualization of the CPU at that level, so that Virtual Box can successfully launch virtual machines, or alternatively, having to configure your Windows 10 environment to disable Hyper-V to get you also in a comfortable position to launch virtual machines. Anyway, if that was not your case, and new machines are available to you then we are in a great position to get started.

Choose a directory that you would like your cluster to work on, in this particular scenario because we are trying to setup a minimum of 3 nodes and 1 master in our cluster, we will require at least 4 virtual machines to start with. The suggested approach is to create a folder structure like the following:

```sh
cluster>
  --> nn0 # name node folder
  --> dn1 # data node 1
  --> dn2 # data node 2
  --> dn3 # data node 3
```

Each of the folders will require the initialization of a Vagrant file with the following characteristics:

```sh
cd nn0 # position in the first folder to work out the installation
vagrant init ubuntu/trusty64 # Creation of the vagrant environment in the local folder
```

The result of the last operation is the creation of the **`Vagrant`** file in the current working directory and the **`.vagrant`** folder which contains the repository of the states of your newly created virtual machine

Now we will have to customize this file in order to be able to perform the further configurations of Hadoop in its most pure state.

Your file should end up with a configuration like the following:

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "hadoop272"

  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"
  config.ssh.insert_key = true

  config.vm.network "public_network"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
  end

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y zsh git
    cd /home/vagrant
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh
  SHELL
end
```

By exploring the code you will find that there is some extras like `zsh` and `git` included in the download section, whilst this is not a requirement for Hadoop to work, I consider them handy to have if orchestration and workflow optimization is required, and both tools are really boosters when it comes to simplify the workflow of configuration or typing commands in the terminal, I strongly recommend look into `oh-my-zsh` and `tmux` as they provide essential tools to manipulate multiple terminals or command prompts simultaneously and therefore speeding the time to get things up and running in your system.

Once this configuration is ready, we are ready to launch the machine that will serve as our name node in Hadoop. Now you can proceed to launch the virtual box, because most probably it will have to download it for the first time now.

```sh
vagrant up
```

I will recommend _you go and grab a coffee_.

Once the command has finalized to download and initialize your machine, you will be ready to connect to your machine, typically you will use `ssh` to gain access to the guest operating system. Configuring SSH in Windows should be a stright forward activity, but if its not, my recommendation is to use a canned version of a modern terminal like `babun` or `Cmder` which will include the *nix* libraries portability to perform this operation.

Ok, let's get into the core of this post, and log into this machine for once!

```sh
vagrant ssh
password: vagrant  # this is specified in your Vagrant file config.ssh.password
```

Once in, you should have a fresh installation of Ubuntu 14.04.05 Server LTS

```sh
$ lsb_release -a  # Linux Distribution version
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 14.04.5 LTS
Release:        14.04
Codename:       trusty

$ uname -r # Kernel version
3.13.0-93-generic
```

This confirms that your box is configured with the expected operative system that will allow us to complete this tutorial in the fail-fast-recover-quick way.

Next step is to download the latest Hadoop distribution from the Apache website, you can achieve that by doing the following:

```sh
# Downloading from Apache mirror sites, perhaps choose a mirror close to your country
# the one used here is one close to Valencia, Spain
wget http://apache.rediris.es/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz

# Next we proceed to unpack the software in our home directory
tar -zxvf hadoop-2.7.2.tar.gz

# Next we will move to the hadoop folder and explore its contents
cd hadoop-2.7.2

# And confirm that software is available
$ ls -l
total 56
drwxr-xr-x 2 vagrant vagrant  4096 Jan 26  2016 bin
drwxr-xr-x 3 vagrant vagrant  4096 Jan 26  2016 etc
drwxr-xr-x 2 vagrant vagrant  4096 Jan 26  2016 include
drwxr-xr-x 3 vagrant vagrant  4096 Jan 26  2016 lib
drwxr-xr-x 2 vagrant vagrant  4096 Jan 26  2016 libexec
-rw-r--r-- 1 vagrant vagrant 15429 Jan 26  2016 LICENSE.txt
drwxrwxr-x 2 vagrant vagrant  4096 Aug 23 11:48 logs
-rw-r--r-- 1 vagrant vagrant   101 Jan 26  2016 NOTICE.txt
-rw-r--r-- 1 vagrant vagrant  1366 Jan 26  2016 README.txt
drwxr-xr-x 2 vagrant vagrant  4096 Jan 26  2016 sbin
drwxr-xr-x 4 vagrant vagrant  4096 Jan 26  2016 share

```

#### Installing Java by Oracle
Ok so Hadoop is installed successfully in our new machine! first step completed.
Now in order to execute Hadoop we need the Java Runtime Environment (JRE), and preferable just in case you are planning to implement some MapReduce jobs or play a bit more indeepth with the technology, is advisable to have the Java Development Kit (JDK). Let's proceed and setup our machine with Java


```sh

# When propmpted press <ENTER> to confirm you want to add this repository to the Ubuntu lists
sudo add-apt-repository ppa:web8upd8team/java

# Update your sources, to confirm new addition
sudo apt-get update

# Install Oracle, a new screen will appear to accept the License Terms, just press <TAB> and <OK>
sudo apt-get install -y oracle-java7-installer

# Let's confirm that everything went fine by trying java
$ java -version
java version "1.8.0_101"
Java(TM) SE Runtime Environment (build 1.8.0_101-b13)
Java HotSpot(TM) 64-Bit Server VM (build 25.101-b13, mixed mode)

```

Excellent our only pre-requisite is met, and in essence we should be good to go, and no more downloads required.
Now the common approach at this stage when running a single node or all-in-one approach is to go to the `sbin` folder and launch the `start-dfs.sh` and `start-yarn.sh` programs, but we mentioned that we don't want the easy things, and that we will be reverse engineering the launching of the daemons used in this distribution of Hadoop, therefore let's just first explore the call stack of the daemon so that we can get into the calling command that launches the individual services.

> Expect a verbose output on this command, what we are doing is following up the route of commands a process initiate, to give us an idea of where this commands is taking us, and where to diagnose potential failures, so that we understand the plumbing behind the daemons in Hadoop.

```sh
# We are trying to launch the Distributed File System without any configuration  whatsoever and finding out if this will magically work!
 strace -f -e trace=process bash -c 'sbin/start-dfs.sh'

# At some point, if this is the first time, you will be prompted to enter the password of this SSH session, in something like:
The authenticity of host '0.0.0.0 (0.0.0.0)' can\'t be established.
ECDSA key fingerprint is b0:47:44:3e:ce:ec:89:a1:59:63:49:75:ef:26:d4:cd.
Are you sure you want to continue connecting (yes/no)? yes

```

Not to get terrified at this stage but just to give you a small hint of the footprint of what that line of code triggered, let's start with the fact that `PID 7973` and ended in `PID 9168` so if my mathematics are not wrong, there were `1195` sub-processes or commands initiated by this simple command. It may appear like finding a needle in a haystack, but don't worry, we are just starting and this is just going to get more fun each step at the time.

> **COMPLEXITY:** You can be served a plate of Spaghetti, and see a sort of a mess in the plate, but at the end of the day, there are just strings of pasta, if you grab one by one, you will be able to see that is a beautiful composition of linear strings all dancing together and baptized in a, hopefully, great tomato sauce
