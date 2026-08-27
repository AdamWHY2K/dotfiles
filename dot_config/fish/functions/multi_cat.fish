function cat --description 'multi cat: bat for text, specialised viewers for other files'
    set args
    for arg in $argv
        if test "$arg" != --raw
            set -a args "$arg"
        end
    end

    # use real cat when --raw
    if contains -- --raw $argv
        command cat $args
        return
    end

    # read stdin
    if test (count $args) -eq 0
        bat --style header,snip,changes
        return
    end

    for file in $args
        if not test -f "$file"
            bat --style header,snip,changes -- "$file"
            continue
        end

        set extension (string lower -- (string match -r '\.[^.]+$' -- "$file"))
        switch $extension
            # Images
            case '.png' '.jpg' '.jpeg' '.gif' '.webp' '.bmp' '.tif' '.tiff' '.avif' '.svg' '.heic' '.heif'
                lsix "$file"
                # Word
            case '.docx' '.doc'
                doxx --color -- "$file"
                # PDF
            case '.pdf'
                pdftotext -layout -- "$file" -
                # Markdown
            case '.md' '.markdown'
                glow -- "$file"
                # Structured data
            case '.yaml' '.yml' '.json'
                yq . -- "$file"
                # Tabular data
            case '.csv' '.tsv' '.xlsx' '.xls' '.ods'
                vd -- "$file"
                # Book
            case '.epub'
                pandoc --to=plain -- "$file"
                # Archive
            case '.zip' '.7z' '.rar' '.tar' '.gz' '.bz2' '.xz' '.zst'
                atool --list -- "$file"
                # Media
            case '.mp3' '.flac' '.ogg' '.opus' '.wav' '.m4a' '.mp4' '.mkv' '.webm' '.avi' '.mov'
                mediainfo -- "$file"

                # inspect the actual file type when no recognised file extension
            case '*'
                set mime (file --brief --mime-type -- "$file")
                switch $mime
                    # Images
                    case 'image/*'
                        lsix -- "$file"
                        # Word
                    case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' \
                        application/msword
                        doxx --color -- "$file"
                        # PDF
                    case application/pdf
                        pdftotext -layout -- "$file" -
                        # Markdown
                    case text/markdown
                        glow -- "$file"
                        # Structured data
                    case application/json \
                        'application/ld+json' \
                        application/yaml \
                        text/yaml \
                        text/x-yaml
                        yq . -- "$file"
                        # Tabular data
                    case text/csv \
                        text/tab-separated-values \
                        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' \
                        'application/vnd.ms-excel' \
                        'application/vnd.oasis.opendocument.spreadsheet'
                        vd -- "$file"
                        # Book
                    case 'application/epub+zip'
                        pandoc --to=plain -- "$file"
                        # Archive
                    case application/zip \
                        application/x-7z-compressed \
                        'application/vnd.rar' \
                        application/x-rar-compressed \
                        application/x-tar \
                        application/gzip \
                        application/x-gzip \
                        application/x-bzip2 \
                        application/x-xz \
                        application/zstd
                        atool --list -- "$file"
                        # Audio
                    case 'audio/*'
                        mediainfo -- "$file"
                        # Video
                    case 'video/*'
                        mediainfo -- "$file"
                        # Everything else
                    case '*'
                        bat --style header,snip,changes -- "$file"
                end
        end
    end
end
