local utils = require("dired.utils")
local M = {}

-- function to use vim filetype parser
function M.get_filetype(filename, filetype)
    if filetype == "file" then
        if filename ~= nil then

            -- Make test files with priority, otherwise it will get file type instead of the test icon
            if string.find(string.lower(filename), "test") or string.find(string.lower(filename), "spec") then
                return "test"
            end

            -- Some file types have to be detected by name
            if string.find(string.lower(filename), "docker") then
                return "dockerfile"
            elseif string.find(string.lower(filename), "blade") then
                return "blade"
            elseif string.find(string.lower(filename), "sqlite") then
                return "sql"
            elseif string.find(string.lower(filename), "webpack") then
                return "webpack"
            elseif string.lower(filename) == ".env" then
                return "env"
            elseif string.lower(filename) == ".rspec" then
                return "ruby"
            elseif string.lower(filename) == ".htaccess" then
                return "conf"
            elseif string.lower(filename) == ".gitattributes" then
                return "git"
            elseif string.lower(filename) == ".gitconfig" then
                return "git"
            elseif string.lower(filename) == ".editorconfig" then
                return "editorconfig"
            elseif string.lower(filename) == "gruntfile.coffee" then
                return "grunt"
            elseif string.lower(filename) == "gruntfile.js" then
                return "grunt"
            elseif string.lower(filename) == "gruntfile.ls" then
                return "grunt"
            elseif string.lower(filename) == "gulpfile.coffee" then
                return "gulp"
            elseif string.lower(filename) == "gulpfile.js" then
                return "gulp"
            elseif string.lower(filename) == "gulpfile.ls" then
                return "gulp"
            elseif string.lower(filename) == "mix.lock" then
                return "elixir"
            elseif string.lower(filename) == "dropbox" then
                return "dropbox"
            elseif string.lower(filename) == ".ds_store" then
                return "conf"
            elseif string.lower(filename) == ".gitconfig" then
                return "git"
            elseif string.lower(filename) == ".gitignore" then
                return "git"
            elseif string.lower(filename) == ".gitattributes" then
                return "conf"
            elseif string.lower(filename) == ".gitlab-ci.yml" then
                return "gitlab"
            elseif string.lower(filename) == ".bashrc" then
                return "conf"
            elseif string.lower(filename) == ".zshrc" then
                return "conf"
            elseif string.lower(filename) == ".zshenv" then
                return "conf"
            elseif string.lower(filename) == ".zprofile" then
                return "conf"
            elseif string.lower(filename) == ".vimrc" then
                return "vim"
            elseif string.lower(filename) == ".gvimrc" then
                return "vim"
            elseif string.lower(filename) == "_vimrc" then
                return "vim"
            elseif string.lower(filename) == "_gvimrc" then
                return "vim"
            elseif string.lower(filename) == ".bashprofile" then
                return "conf"
            elseif string.lower(filename) == ".bash_profile" then
                return "conf"
            elseif string.lower(filename) == "favicon.ico" then
                return "ico"
            elseif string.lower(filename) == "license" then
                return "pem"
            elseif string.lower(filename) == "node_modules" then
                return "node"
            elseif string.lower(filename) == "procfile" then
                return "procfile"
            elseif string.lower(filename) == "compose.yaml" then
                return "dockerfile"
            elseif string.lower(filename) == "containerfile" then
                return "dockerfile"
            elseif string.lower(filename) == "rakefile" then
                return "ruby"
            elseif string.lower(filename) == "config.ru" then
                return "ruby"
            elseif string.lower(filename) == "gemfile" then
                return "ruby"
            elseif string.lower(filename) == "makefile" then
                return "conf"
            elseif string.lower(filename) == "cmakelists.txt" then
                return "conf"
            elseif string.lower(filename) == "robots.txt" then
                return "robots"
            elseif string.lower(filename) == ".eslintignore" then
                return "eslint"
            elseif string.lower(filename) == ".eslintrc" then
                return "eslint"
            elseif string.lower(filename) == ".npmrc" then
                return "npm"
            elseif string.lower(filename) == ".npmignore" then
                return "npm"
            end


            -- Some file types have to be detected by extension
            local splited_filename = utils.str_split(filename, ".", true)
            local file_extension = splited_filename[utils.tableLength(splited_filename)]

            if file_extension == "txt" then
                return "text"
            elseif file_extension == "ts" then
                return "typescript"
            elseif file_extension == "html" then
                return "html"
            elseif file_extension == "yaml" then
                return "conf"
            elseif file_extension == "yml" then
                return "conf"
            elseif file_extension == "toml" then
                return "conf"
            elseif file_extension == "conf" then
                return "conf"
            elseif file_extension == "ini" then
                return "conf"
            elseif file_extension == "ex" then
                return "elixir"
            elseif file_extension == "eot" then
                return "font"
            elseif file_extension == "ttf" then
                return "font"
            elseif file_extension == "woff" then
                return "font"
            elseif file_extension == "woff2" then
                return "font"
            elseif file_extension == "otf" then
                return "font"
            elseif file_extension == "sass" then
                return "sass"
            elseif file_extension == "scss" then
                return "scss"
            elseif file_extension == "jsx" then
                return "jsx"
            elseif file_extension == "tsx" then
                return "tsx"
            elseif file_extension == "gif" then
                return "gif"
            elseif file_extension == "png" then
                return "png"
            elseif file_extension == "jpeg" then
                return "jpeg"
            elseif file_extension == "jpg" then
                return "jpg"
            elseif file_extension == "bmp" then
                return "bmp"
            elseif file_extension == "webp" then
                return "webp"
            elseif file_extension == "ico" then
                return "ico"
            elseif file_extension == "cpp" then
                return "cpp"
            elseif file_extension == "c++" then
                return "cpp"
            elseif file_extension == "cxx" then
                return "cpp"
            elseif file_extension == "cc" then
                return "cpp"
            elseif file_extension == "cp" then
                return "cpp"
            elseif file_extension == "h" then
                return "header"
            elseif file_extension == "hh" then
                return "header"
            elseif file_extension == "hpp" then
                return "header"
            elseif file_extension == "hxx" then
                return "header"
            elseif file_extension == "pyc" then
                return "python"
            elseif file_extension == "pyo" then
                return "python"
            elseif file_extension == "pyd" then
                return "python"
            elseif file_extension == "nix" then
                return "nix"
            elseif file_extension == "hsl" then
                return "haskell"
            elseif file_extension == "erl" then
                return "erlang"
            elseif file_extension == "sh" then
                return "shell"
            elseif file_extension == "bat" then
                return "shell"
            elseif file_extension == "fish" then
                return "shell"
            elseif file_extension == "bash" then
                return "shell"
            elseif file_extension == "zsh" then
                return "shell"
            elseif file_extension == "ksh" then
                return "shell"
            elseif file_extension == "csh" then
                return "shell"
            elseif file_extension == "awk" then
                return "shell"
            elseif file_extension == "ps1" then
                return "shell"
            elseif file_extension == "ml" then
                return "ml"
            elseif file_extension == "mli" then
                return "ml"
            elseif file_extension == "mustache" then
                return "mustache"
            elseif file_extension == "hbs" then
                return "mustache"
            elseif file_extension == "sql" then
                return "sql"
            elseif file_extension == "db" then
                return "sql"
            elseif file_extension == "dump" then
                return "sql"
            elseif file_extension == "clj" then
                return "clj"
            elseif file_extension == "cljc" then
                return "clj"
            elseif file_extension == "edn" then
                return "cljs"
            elseif file_extension == "cljs" then
                return "cljs"
            elseif file_extension == "scala" then
                return "scala"
            elseif file_extension == "sc" then
                return "scala"
            elseif file_extension == "sbt" then
                return "scala"
            elseif file_extension == "go" then
                return "go"
            elseif file_extension == "dart" then
                return "dart"
            elseif file_extension == "xml" then
                return "xml"
            elseif file_extension == "ant" then
                return "xml"
            elseif file_extension == "axml" then
                return "xml"
            elseif file_extension == "ccxml" then
                return "xml"
            elseif file_extension == "clixml" then
                return "xml"
            elseif file_extension == "sln" then
                return "csproj"
            elseif file_extension == "suo" then
                return "csproj"
            elseif file_extension == "rs" then
                return "rust"
            elseif file_extension == "rlib" then
                return "rust"
            elseif file_extension == "exs" then
                return "elixir"
            elseif file_extension == "eex" then
                return "elixir"
            elseif file_extension == "leex" then
                return "elixir"
            elseif file_extension == "heex" then
                return "elixir"
            elseif file_extension == "vim" then
                return "vim"
            elseif file_extension == "ai" then
                return "ai"
            elseif file_extension == "psd" then
                return "psd"
            elseif file_extension == "psb" then
                return "psb"
            elseif file_extension == "jl" then
                return "julia"
            elseif file_extension == "vue" then
                return "vue"
            elseif file_extension == "swift" then
                return "swift"
            elseif file_extension == "xcplayground" then
                return "swift"
            elseif file_extension == "r" then
                return "r"
            elseif file_extension == "sol" then
                return "sol"
            elseif file_extension == "pem" then
                return "pem"
            elseif file_extension == "asm" then
                return "asm"
            elseif file_extension == "cobol" then
                return "cobol"
            elseif file_extension == "doc" then
                return "doc"
            elseif file_extension == "docx" then
                return "doc"
            elseif file_extension == "log" then
                return "log"
            elseif file_extension == "mdx" then
                return "markdown"
            elseif file_extension == "m4v" then
                return "mov"
            elseif file_extension == "mkv" then
                return "mov"
            elseif file_extension == "mov" then
                return "mov"
            elseif file_extension == "mp4" then
                return "mov"
            elseif file_extension == "mp3" then
                return "mov"
            elseif file_extension == "ogg" then
                return "mov"
            elseif file_extension == "pl" then
                return "pl"
            elseif file_extension == "pm" then
                return "pl"
            elseif file_extension == "pp" then
                return "pp"
            elseif file_extension == "ppt" then
                return "ppt"
            elseif file_extension == "pro" then
                return "prolog"
            elseif file_extension == "rproj" then
                return "prolog"
            elseif file_extension == "schtml" then
                return "razor"
            elseif file_extension == "wasm" then
                return "razor"
            elseif file_extension == "webm" then
                return "mov"
            elseif file_extension == "xls" then
                return "xls"
            elseif file_extension == "xlsx" then
                return "xls"
            elseif file_extension == "exe" then
                return "exe"
            end

            -- Try to make vim recognise file type
            local vim_estimated_filetype = vim.filetype.match({ filename = filename })

            if vim_estimated_filetype ~= nil then
                return vim_estimated_filetype
            else
                return "text"
            end
        else
            return "text"
        end
    else
        return "directory"
    end
end

function M.get_icon_by_filetype(filetype)
    if filetype == "directory" then
        return " "
    elseif filetype == "link" then
        return "⮕ "
    elseif filetype == "file" then
        return " "
    elseif filetype == "text" then
        return " "
    elseif filetype == "test" then
        return " "
    elseif filetype == "gitignore" then
        return " "
    elseif filetype == "git" then
        return " "
    elseif filetype == "gitconfig" then
        return " "
    elseif filetype == "gitattributes" then
        return " "
    elseif filetype == "editorconfig" then
        return " "
    elseif filetype == "toml" then
        return " "
    elseif filetype == "apache" then
        return " "
    elseif filetype == "yaml" then
        return " "
    elseif filetype == "conf" then
        return " "
    elseif filetype == "markdown" then
        return " "
    elseif filetype == "lua" then
        return " "
    elseif filetype == "javascript" then
        return " "
    elseif filetype == "typescript" then
        return " "
    elseif filetype == "html" then
        return " "
    elseif filetype == "python" then
        return " "
    elseif filetype == "rust" then
        return " "
    elseif filetype == "php" then
        return " "
    elseif filetype == "c" then
        return " "
    elseif filetype == "cpp" then
        return " "
    elseif filetype == "header" then
        return " "
    elseif filetype == "cs" then
        return "󰌛 "
    elseif filetype == "ruby" then
        return " "
    elseif filetype == "java" then
        return " "
    elseif filetype == "sql" then
        return " "
    elseif filetype == "clj" then
        return " "
    elseif filetype == "cljs" then
        return " "
    elseif filetype == "go" then
        return " "
    elseif filetype == "haskell" then
        return " "
    elseif filetype == "lhaskell" then
        return " "
    elseif filetype == "clojure" then
        return " "
    elseif filetype == "elm" then
        return " "
    elseif filetype == "css" then
        return " "
    elseif filetype == "gif" then
        return " "
    elseif filetype == "png" then
        return " "
    elseif filetype == "jpeg" then
        return " "
    elseif filetype == "jpg" then
        return " "
    elseif filetype == "bmp" then
        return " "
    elseif filetype == "webp" then
        return " "
    elseif filetype == "ico" then
        return " "
    elseif filetype == "json" then
        return " "
    elseif filetype == "jsonc" then
        return " "
    elseif filetype == "svg" then
        return " "
    elseif filetype == "elixir" then
        return " "
    elseif filetype == "eelixir" then
        return " "
    elseif filetype == "scheme" then
        return "󰘧 "
    elseif filetype == "ml" then
        return "󰘧 "
    elseif filetype == "mli" then
        return "󰘧 "
    elseif filetype == "ocaml" then
        return "󰘧 "
    elseif filetype == "dockerfile" then
        return "󰡨 "
    elseif filetype == "font" then
        return " "
    elseif filetype == "sass" then
        return " "
    elseif filetype == "scss" then
        return " "
    elseif filetype == "jsx" then
        return " "
    elseif filetype == "tsx" then
        return " "
    elseif filetype == "nix" then
        return "'"
    elseif filetype == "shell" then
        return " "
    elseif filetype == "zsh" then
        return " "
    elseif filetype == "bash" then
        return " "
    elseif filetype == "mustache" then
        return " "
    elseif filetype == "scala" then
        return " "
    elseif filetype == "vim" then
        return " "
    elseif filetype == "ai" then
        return " "
    elseif filetype == "psd" then
        return " "
    elseif filetype == "psb" then
        return " "
    elseif filetype == "julia" then
        return " "
    elseif filetype == "vue" then
        return "﵂ "
    elseif filetype == "swift" then
        return " "
    elseif filetype == "r" then
        return "ﳒ "
    elseif filetype == "sol" then
        return "ﲹ "
    elseif filetype == "pem" then
        return " "
    elseif filetype == "grunt" then
        return " "
    elseif filetype == "gulp" then
        return " "
    elseif filetype == "dropbox" then
        return " "
    elseif filetype == "gitlab" then
        return "'"
    elseif filetype == "node" then
        return " "
    elseif filetype == "robots" then
        return "ﮧ "
    elseif filetype == "procfile" then
        return " "
    elseif filetype == "xml" then
        return "󰗀 "
    elseif filetype == "dart" then
        return " "
    elseif filetype == "env" then
        return " "
    elseif filetype == "csv" then
        return ""
    elseif filetype == "postscr" then
        return " "
    elseif filetype == "awk" then
        return " "
    elseif filetype == "dosbatch" then
        return " "
    elseif filetype == "diff" then
        return " "
    elseif filetype == "erlang" then
        return " "
    elseif filetype == "fish" then
        return " "
    elseif filetype == "fsharp" then
        return " "
    elseif filetype == "haml" then
        return " "
    elseif filetype == "handlebars" then
        return " "
    elseif filetype == "heex" then
        return " "
    elseif filetype == "dosini" then
        return " "
    elseif filetype == "make" then
        return " "
    elseif filetype == "javascriptreact" then
        return " "
    elseif filetype == "typescriptreact" then
        return " "
    elseif filetype == "less" then
        return " "
    elseif filetype == "ps1" then
        return "󰨊 "
    elseif filetype == "psb" then
        return " "
    elseif filetype == "psd" then
        return " "
    elseif filetype == "rmd" then
        return " "
    elseif filetype == "solution" then
        return " "
    elseif filetype == "csproj" then
        return " "
    elseif filetype == "solidity" then
        return " "
    elseif filetype == "twig" then
        return " "
    elseif filetype == "cobol" then
        return "⚙ "
    elseif filetype == "graphql" then
        return " "
    elseif filetype == "kotlin" then
        return " "
    elseif filetype == "nim" then
        return " "
    elseif filetype == "pdf" then
        return " "
    elseif filetype == "prisma" then
        return " "
    elseif filetype == "sbt" then
        return " "
    elseif filetype == "zig" then
        return " "
    elseif filetype == "eslint" then
        return " "
    elseif filetype == "npm" then
        return " "
    elseif filetype == "asm" then
        return " "
    elseif filetype == "coffee" then
        return " "
    elseif filetype == "doc" then
        return "󰈬 "
    elseif filetype == "exe" then
        return " "
    elseif filetype == "log" then
        return "󰌱 "
    elseif filetype == "mov" then
        return " "
    elseif filetype == "pl" then
        return " "
    elseif filetype == "pp" then
        return " "
    elseif filetype == "ppt" then
        return "󰈧 "
    elseif filetype == "prolog" then
        return " "
    elseif filetype == "rproj" then
        return "󰗆 "
    elseif filetype == "blade" then
        return "󱦗 "
    elseif filetype == "razor" then
        return "󱦗 "
    elseif filetype == "wasm" then
        return " "
    elseif filetype == "xls" then
        return "󰈛 "
    elseif filetype == "webpack" then
        return "󰜫 "
    end
    return " "
end

return M
