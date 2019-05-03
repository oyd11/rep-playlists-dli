#!/usr/bin/env julia06

# Poor-man's "spaced-repetition" playlist creator 
# for audio playlists from http://fieldsupport.dliflc.edu :: 
# "language survival kits"


# Julia 0.6 script:


#lang = "georgian"
#lang = "tigrinya"
#lang = "tigrinya"
#lang = "indonesian"

if !isdefined(:lang) && length(ARGS) < 1
    error("missing Language arg, for example: 'tigrinya'")
end

if !isdefined(:lang)
	lang = ARGS[1]
end

n_reps = 3
run_length = 7
step_size = 7

audioTopdir = "./$lang/"
outPlaylistDir = "./$lang-rep/"

using Glob

get_sept_str() = joinpath("_","")[end:end]
sep_str = get_sept_str()

function get_audio_list(d::String)
    all_audio = glob("*.mp3", d)
    sounds = glob("00_*.mp3", d)
    phrases = setdiff( all_audio, sounds)
    return phrases, sounds
end

# filenames like "./en_gg_ac_01_03.mp3"

function mk_reps(l)
    @assert length(l) != 0
    s = 1 : step_size : length(l)
	println("length: $(length(l))")
    ranges = [from:to for (from,to) in zip(s,vcat(s[2:end]-1, length(l)))]
    rep_list = map(ranges) do r
        group = l[r]
        perms = map(x->shuffle(group), 1:n_reps-1)
        vcat(group,perms... )
    end
    vcat(rep_list...)
end


mkpath(outPlaylistDir )

h1 = "#EXTM3U"

cd(lang) do
    for path_name in glob("*/")
        p = splitdir(path_name)[1]
        println(p)
        phrases, sounds = get_audio_list(p)
	println("# phrases: $(length(phrases))")
        let 
            out_filename = "../$outPlaylistDir/$p.m3u8"
            out_string = join([h1, sounds..., phrases...],"\n")
            info("out_filename: $out_filename")
            open(out_filename, "w") do f
                print(f, out_string)
            end
        end
        let
            out_filename = "../$outPlaylistDir/rep$(n_reps)_$p.m3u8" 
            rep_phrases = mk_reps(phrases)
            out_string = join([h1, rep_phrases...],"\n")
            info("out_filename: $out_filename")
            open(out_filename, "w") do f
                print(f, out_string)
            end
        end
    end # for
end # cd

