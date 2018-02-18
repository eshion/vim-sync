" Defines the filenames of the executable file to execute to synchronize your sources
" The executable file will be searched from the directory of the current file
" You can provide multiple filename, separate with a ","
" To look backward in the directory tree add ";" at the end of the filname
" Example :
"   - let g:sync_exe_filenames = '.sync;'
"     Looks backward for a file named ".sync"
"   - let g:sync_exe_filenames = '.sync;,.sync.sh;'
"     Looks backward for a file named ".sync". If not found then looks backward for a file named ".sync.sh"
if !exists('g:sync_exe_filenames')
    let g:sync_exe_filenames = '.sync;'
endif

" When editing a symlink, only synchronized the target
" By default, only the target is synchronized
" Might be usefull is you use a lots of symlinks and don't want to have
" to push them manually on the remote.
if !exists('g:sync_push_symlink_too')
    let g:sync_push_symlink_too = 0
endif

" Defines if the upload should be asynchronous
" Requires the Asyncryn plugin
if !exists('g:sync_async_upload')
    let g:sync_async_upload = 1
endif

" Checks if the executable file was found and is executable by the current user
function! s:SyncExeIsValid(filepath)
    return !empty(a:filepath) && sync#files#IsExecutable(a:filepath)
endfunction

" Gets the full path of the executable file, looking from a given path
function! s:SyncGetExe(path)
    let l:exe = sync#files#FindFirst(g:sync_exe_filenames, a:path)

    if !empty(l:exe)
        let l:exe = fnamemodify(l:exe, ':p')
    endif

    return l:exe
endfunction

" Checks if we must use AsyncRun or not
function! s:SyncUseAsyncRun()
    return g:sync_async_upload && exists(':AsyncRun')
endfunction

" Create the shell command to execute to synchronize a file
function! s:SyncCreateShellCommand(action, filepath)
    let l:exe_fullpath = s:SyncGetExe(fnamemodify(a:filepath, ':h'))
    let l:filename     = fnamemodify(a:filepath, ':t')

    if !s:SyncExeIsValid(l:exe_fullpath) || l:filename ==# fnamemodify(l:exe_fullpath, ':t')
        return ''
    endif

    let l:exe_path           = fnamemodify(l:exe_fullpath, ':h')
    let l:file_relative_path = sync#files#GetRelativePathTo(a:filepath, l:exe_path)

    return printf(
        \'%s %s %s %s',
        \shellescape(l:exe_fullpath),
        \a:action,
        \shellescape(l:file_relative_path),
        \shellescape(l:filename)
    \)
endfunction

" Creates the command to execute to upload a file
" Checks if we should upload the symlink and if we can use AcynRun
function! s:SyncCreateVimUploadCommand()
    let l:action           = 'upload'
    let l:symlink_fullpath = expand('%:p')
    let l:file_fullpath    = resolve(l:symlink_fullpath)
    let l:symlink_command  = ''
    let l:file_command     = s:SyncCreateShellCommand(l:action, l:file_fullpath)
    let l:command          = ''

    if empty(l:file_command)
        return ''
    endif

    if g:sync_push_symlink_too && sync#files#IsSymlink(l:symlink_fullpath)
        let l:symlink_command = s:SyncCreateShellCommand(l:action, l:symlink_fullpath)

        if empty(l:symlink_command)
            return ''
        endif

        if s:SyncUseAsyncRun()
            let l:command = printf(
                \'AsyncRun -post=AsyncRun\ %s %s',
                \substitute(l:symlink_command, ' ', '\\ ', 'g'),
                \l:file_command
            \)
        else
            "execute "!'./test.sh' 'un' 'deux'" | execute "!'./test.sh' 'trois' 'quatre'"
            let l:command = printf('!%s && %s', l:file_command, l:symlink_command)
        endif
    else
        if s:SyncUseAsyncRun()
            let l:command = 'AsyncRun ' . l:file_command
        else
            let l:command = '!' . l:file_command
        endif
    endif

    echo l:command
    return l:command
endfunction

" Creates the command to execute to download a file
function! s:SyncCreateVimDownloadCommand()
    " Never download asynchronously because we must wait for the download to
    " complete before reloading the file
    " Doesn't download the symlink because there is no point to do so
    " If we edit it, it already exists and we just want the content of the target
    let l:command = s:SyncCreateShellCommand('download', resolve(expand('%:p')))

    if empty(l:command)
        return ''
    endif

    return '!' . l:command
endfunction

function! s:SyncExecuteCommand(command)
    if empty(a:command)
        return
    endif

    silent execute a:command

    return
endfunction

" Upload the file
function! g:SyncUploadFile()
    call s:SyncExecuteCommand(s:SyncCreateVimUploadCommand())

    return
endfunction

" Download the file, all current changes will be lost
function! g:SyncDownloadFile()
    call s:SyncExecuteCommand(s:SyncCreateVimDownloadCommand())
    execute 'edit!' expand('%')
    redraw!

    return
endfunction

" Standard mappings
nmap <leader>su :call g:SyncUploadFile()<CR>
nmap <leader>sd :call g:SyncDownloadFile()<CR>
