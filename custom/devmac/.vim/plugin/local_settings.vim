if exists('g:loaded_arkku_local_settings')
    finish
else
    let g:loaded_arkku_local_settings=1
endif

"let g:syntastic_swift_checkers = [ 'swiftpm', 'swiftlint' ]
let g:syntastic_swift_checkers = []
let g:syntastic_c_checkers = []
let g:syntastic_cpp_checkers = []
let g:syntastic_objc_checkers = []

let g:ale_c_clang_options = '--std=c11 -Wall -Wextra'
let g:ale_cpp_clang_options = '--std=c++17 -Wall -Wextra'
let g:ale_objc_clang_options = '-Wall -Wextra'

let g:ale_linters = {'c': ['clang'], 'cpp': ['clang']}
