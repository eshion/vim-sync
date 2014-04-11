vim-sync
========

Automatic sync local buffer to remote in vim


Installation
----

Install using [bundle],[vundle],[pathogen] or your favorite Vim package manager.

Usage
----

create a execute file called .sync in your project directory.
e.g. /project_dir/ is your project dirctory and the execute file is /project_dir/.sync

    <leader>su
    Upload current buffer file, it will execute the command: project_dir/.sync upload current_buffer_fold current_file_name
    
    <leader>sd
    Download current buffer file, it will execute the command: project_dir/.sync download current_buffer_fold current_file_name

some execute config
----
* rsync:
    
* sftp:
    
* ftp:


Alias
----
  
If you want to another command, write following like.

Ctrl+u  
    `nnoremap <C-U> <ESC>:call SyncUploadFile()<CR>`
    
Ctrl+d  
    `nnoremap <C-U> <ESC>:call SyncDownloadFile()<CR>`
    
[bundle]:https://github.com/bundler/bundler/
[vundle]:https://github.com/gmarik/vundle/
[pathogen]:https://github.com/tpope/vim-pathogen/

