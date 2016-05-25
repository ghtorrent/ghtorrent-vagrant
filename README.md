# ghtorrent-vagrant
A Vagrant box with Puppet provisioning for testing GHTorrent

This will create a Debian 8 based virtual machine with all the required 
infrastructure (MongoDB, MySQL, RabbitMQ) to test GHTorrent and run it 
locally for smaller projects.

## Installation

* Install [VirtualBox](https://www.virtualbox.org)
* Install [Vagrant](https://www.vagrantup.com)
  * On Debian 8, you can use `apt-get install vagrant` 
  * On the Mac, you can use `brew cask install vagrant`
  * For other platforms, you can try [this link](https://www.vagrantup.com/downloads.html)

* Clone the repository (`git clone https://github.com/ghtorrent/ghtorrent-vagrant.git`)

* You will need a GitHub API key. You can create one using the process described 
[here (Fair Use)](http://ghtorrent.org/raw.html)


## Running

* Switch to the checked out directory and do: `vagrant up`
* When the provisioning process finishes, do: `vagrant ssh`

This will get you to the command line of the the vagrant VM. You will
notice that the file `config.yaml` exists. Open it and replace the token
field (default value: `abcd`) with the GitHub API key you created before.

### Retrieving info for a single project

To retrieve information for a single repository do
```
$ ght-retrieve-repo -c config.yaml owner repo
```

where `owner` and `repo` are the owner and repo of the GitHub repository
you want to retrieve info for.

`ght-retrieve-repo` accepts lots of command line arguments to restrict
the amount of data in downloads, which can be found using the `--help` switch.

### Listening to GitHub's event stream

You need two steps:

* Run the event collector: `ght-mirror-events -c config.yaml`. This will query the event stream API end point and
then will push events to RabbitMQ.
* Run the data collector: `ght-data-retrieval -c config.yaml`This step will create the necessary queues on 
RabbitMQ and start consuming events from them, in parallel. You can see the contents of the queues by running 
`sudo /usr/sbin/rabbitmqctl list_queues` or by connecting your browser to port `15672` of the virtual machine public
 IP address (find it by `/sbin/ifconfig eth1`).
 
 
This step effectively replicates the main GHTorrent system, as run at [ghtorrent.org](http://ghtorrent.org). 

## Viewing the retrieval results

Data is being collected into two sources

### MongoDB database

(no username/password)

```
$ mongo github
MongoDB shell version: 2.6.11
connecting to: github
> show collections
commit_comments
commits
events
followers
forks
issue_comments
issue_events
issues
org_members
pull_request_comments
pull_requests
repo_collaborators
repo_labels
repos
users
watchers
> db.commits.count()
43
> db.events.find({'actor.login':'gousiosg'}).count()
10
```

### MySQL database
(username/password/database: `ghtorrent`)

```bash
vagrant@debian-jessie:~$ mysql -u ghtorrent -p'ghtorrent' ghtorrent
[...]
mysql> select count(*) from commits;
+----------+
| count(*) |
+----------+
|       10 |
+----------+
1 row in set (0.00 sec)

mysql> select * from projects;
+----+----------------------------------------------------------+----------+-------------------+----------------------------------------------------------------------+----------+---------------------+-------------+---------+
| id | url                                                      | owner_id | name              | description                                                          | language | created_at          | forked_from | deleted |
+----+----------------------------------------------------------+----------+-------------------+----------------------------------------------------------------------+----------+---------------------+-------------+---------+
|  1 | https://api.github.com/repos/gousiosg/github-mirror      |        1 | github-mirror     | Scripts to mirror Github in a cloudy fashion                         | Ruby     | 2011-11-26 13:02:32 |        NULL |       0 |
|  2 | https://api.github.com/repos/ghtorrent/ghtorrent-vagrant |        2 | ghtorrent-vagrant | A Vagrant box with Puppet provisioning for running GHTorrent locally | Puppet   | 2015-09-25 19:56:52 |        NULL |       0 |
+----+----------------------------------------------------------+----------+-------------------+----------------------------------------------------------------------+----------+---------------------+-------------+---------+
2 rows in set (0.00 sec)


```
