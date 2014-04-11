vim-sync
========

Automatic sync local and remote file in vim


Installation
----

Install using [bundle],[vundle],[pathogen] or your favorite Vim package manager.

Usage
----

create a execute file called .sync in your project directory.
e.g. /project_dir/ is your project dirctory and the execute file is /project_dir/.sync. how to write execute file see "some execute config" section.

    <leader>su
    Upload current buffer file, it will execute the command: project_dir/.sync upload current_buffer_fold current_file_name
    
    <leader>sd
    Download current buffer file, it will execute the command: project_dir/.sync download current_buffer_fold current_file_name

some execute config
----
* rsync:
<pre>
    #!/bin/sh
    if [ "upload" == $1 ];then
        rsync -azcuv -e "/bin/ssh -p36000 -q" `dirname $0`/$2/$3 login_name@remote_host:/remote_path/$2/$3
    elif [ 'download' == $1 ];then
        rsync -azcuv -e "/bin/ssh -p36000 -q" login_name@remote_host:/remote_path/$2/$3 `dirname $0`/$2/$3
    fi
</pre>
* sftp:
    
* ftp:


Alias
----
  
If you want to another command, write following like.

Ctrl+u  
    `nnoremap <C-U> <ESC>:call SyncUploadFile()<CR>`
    
Ctrl+d  
    `nnoremap <C-U> <ESC>:call SyncDownloadFile()<CR>`
    
* if you want to auto upload/download file where save/open file, write these code in you .emacs config file:
 
        autocmd BufWritePost * :call SyncUploadFile()
        autocmd BufReadPre * :call SyncDownloadFile()

    
[bundle]:https://github.com/bundler/bundler/
[vundle]:https://github.com/gmarik/vundle/
[pathogen]:https://github.com/tpope/vim-pathogen/

