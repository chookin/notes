https://github.com/Gazler/githug
Githug is designed to give you a practical way of learning git. It has a series of levels, each requiring you to use git commands to arrive at a correct answer.
# 先决条件
Githug requires Ruby 1.8.7 or higher.
# 安装

    gem install githug
若安装出错，

    ERROR:  While executing gem ... (Gem::RemoteFetcher::FetchError)
    Errno::ECONNRESET: Connection reset by peer - SSL_connect (https://api.rubygems.org/quick/Marshal.4.8/github-0.7.2.gemspec.rz)    
那么需要更换gem sources.

    gem sources -r https://rubygems.org/
    gem sources -a https://ruby.taobao.org/
看下ruby源

    gem sources -l
显示如下

    *** CURRENT SOURCES ***
    https://ruby.taobao.org/    
再次执行安装命令即可。
# Starting the Game

After the gem is installed change directory to the location where you want the game-related assets to be stored. Then run githug:

    githug
You will be prompted to create a directory.

No githug directory found, do you wish to create one? [yn]
Type y (yes) to continue, n (no) to cancel and quit Githug.

# Commands

Githug has 4 game commands:

play - The default command, checks your solution for the current level
hint - Gives you a hint (if available) for the current level
reset - Reset the current level or reset the level to a given name or path
levels - List all the levels
