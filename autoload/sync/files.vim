" Find the first existing file in a list
" Uses sync#files#SyncFindAFile
function! sync#files#FindFirst(files, path)
    let l:file = ''

    for l:filename in split(a:files, ',')
        let l:file = sync#files#Find(l:filename, a:path)

        if !empty(l:file)
            return l:file
        endif
    endfor

    return l:file
endfunction

" Find a file, looks backward if a:filename ends with a ";"
function! sync#files#Find(filename, path)
    let l:path     = a:path
    let l:filename = a:filename

    if l:filename =~ ';$'
        let l:path     = l:path . ';'
        let l:filename = substitute(l:filename, ';$', '', '')
    endif

    return findfile(l:filename, l:path)
endfunction

" Get the relative path of a file from path
" Example :
"   sync#files#GetRelativePathTo('/home/user/bin/my-script.sh', '/home')
"   Returns user/bin
function! sync#files#GetRelativePathTo(filename, path)
    execute 'lcd' a:path
    let l:relative_path = fnamemodify(a:filename, ':.:h')
    lcd -

    return l:relative_path
endfunction

" Checks if a file is executable by the current user
function! sync#files#IsExecutable(filepath)
    silent execute '!test -x' a:filepath

    return 0 == v:shell_error
endfunction

" Checks if a file is a symbolic link
function! sync#files#IsSymlink(filepath)
    silent execute '!test -L' a:filepath

    return 0 == v:shell_error
endfunction
