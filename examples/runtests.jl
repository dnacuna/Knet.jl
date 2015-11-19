using Knet, ArgParse, Base.Test

# Uncomment these if you want lots of messages:
import Base.Test: default_handler, Success, Failure, Error
# default_handler(r::Success) = info("$(r.expr)")
default_handler(r::Failure) = warn("FAIL: $(r.expr)")
# default_handler(r::Error)   = warn("$(r.err): $(r.expr)")

load_only = true

s = ArgParseSettings()
@add_arg_table s begin
    ("--all"; action=:store_true)
    ("--twice"; action=:store_true)
    ("--gcheck"; arg_type=Int; default=0)
    ("--linreg"; action=:store_true)
    ("--mnist2d"; action=:store_true)
    ("--mnist2dy"; action=:store_true)
    ("--mnist2dx"; action=:store_true)
    ("--mnist2dxy"; action=:store_true)
    ("--mnist4d"; action=:store_true)
    ("--mnistpixels"; action=:store_true)
    ("--addingirnn"; action=:store_true)
    ("--addinglstm"; action=:store_true)
    ("--rnnlm"; action=:store_true)
    ("--copyseq"; action=:store_true)
    ("--ncelm"; action=:store_true)
    ("--ner"; action=:store_true)
end
opts = parse_args(isempty(ARGS) ? ["--all"] : ARGS, s)
gcheck = opts["gcheck"]
twice = opts["twice"]

if opts["all"] || opts["linreg"]
    include("linreg.jl")
    @time @show test1 = linreg("--gcheck $gcheck")
    #@test test1 == (0.0005497372347062405,32.77256166946498,0.11244349406523031)
    #@test test1 == (0.0005497372347062409,32.77256166946497,0.11244349406522969) # Mon Oct 26 11:10:17 PDT 2015: update uses axpy to scale with gclip&lr
    @test  test1 == (0.0005497846637255734,32.77257400591496,0.11265426200775067) # Wed Nov 18 21:39:18 PST 2015: xavier init
    twice && (@time @show test1 = linreg("--gcheck $gcheck"))
    # 0.739858 seconds (394.09 k allocations: 71.335 MB, 1.23% gc time) Tue Oct 20 18:29:41 PDT 2015
    # 0.731515 seconds (391.62 k allocations: 71.451 MB, 1.21% gc time) Fri Nov  6 12:53:16 PST 2015: new add kernels
end

if opts["all"] || opts["mnist2d"]
    include("mnist2d.jl")
    @time @show test2 = mnist2d("--gcheck $gcheck")
    # @test test2 == (0.10628127f0,24.865438f0,3.5134742f0)
    # @test test2 == (0.10626979f0,24.866688f0,3.5134728f0) # softloss with mask
    # @test test2 == (0.10610757f0,24.87226f0,3.3128357f0)  # 51a1bc1 v0.6.8 improved nan-proofing of softmax Fri Nov  6 12:53:16 PST 2015
    @test   test2 == (0.108679175f0,43.344624f0,3.0013776f0) # Wed Nov 18 21:39:18 PST 2015: xavier init
    twice && (gc(); @time @show test2 = mnist2d("--gcheck $gcheck"))
    # 6.941715 seconds (3.35 M allocations: 151.876 MB, 1.33% gc time) Tue Oct 20 19:15:59 PDT 2015
    # 6.741272 seconds (3.35 M allocations: 151.858 MB, 1.41% gc time) Mon Oct 26 11:10:17 PDT 2015: update uses axpy to scale with gclip&lr
    # 7.031675 seconds (3.47 M allocations: 158.983 MB, 1.31% gc time) Fri Nov  6 12:53:16 PST 2015: new add kernels
    # 6.730379 seconds (3.61 M allocations: 161.998 MB, 1.42% gc time) Wed Nov 18 21:28:22 PST 2015: lcn
end

if opts["all"] || opts["mnist2dy"]
    isdefined(:mnist2d) || include("mnist2d.jl")
    @time @show test3 = mnist2d("--ysparse --gcheck $gcheck")
    #@test test3 == (0.1062698f0,24.866688f0,3.513474f0)
    #@test test3 == (0.10610757f0,24.87226f0,3.3128357f0)  # 51a1bc1 v0.6.8 improved nan-proofing of softmax Fri Nov  6 12:53:16 PST 2015
    @test  test3 == (0.10906915f0,43.341377f0,3.1931002f0)  # Wed Nov 18 21:39:18 PST 2015: xavier init
    twice && (gc(); @time @show test3 = mnist2d("--ysparse --gcheck $gcheck"))
    # 8.478264 seconds (3.59 M allocations: 173.689 MB, 2.06% gc time) Tue Oct 20 19:14:45 PDT 2015
    # 8.205758 seconds (3.59 M allocations: 173.636 MB, 2.14% gc time) Mon Oct 26 11:10:17 PDT 2015: update uses axpy to scale with gclip&lr
    # 8.542426 seconds (3.73 M allocations: 181.290 MB, 2.06% gc time) Fri Nov  6 12:53:16 PST 2015: new add kernels
    # 8.073397 seconds (3.86 M allocations: 184.237 MB, 2.15% gc time) Wed Nov 18 21:28:22 PST 2015: lcn
end

if opts["all"] || opts["mnist2dx"]
    isdefined(:mnist2d) || include("mnist2d.jl")
    @time @show test4 = mnist2d("--xsparse --gcheck $gcheck")

    # @test isapprox(test4[1], 0.10628127f0; rtol=0.005)
    # @test isapprox(test4[2], 24.865437f0; rtol=0.002)
    # @test isapprox(test4[3], 3.5134742f0; rtol=0.02) # cannot compute csru vecnorm

    # 51a1bc1 v0.6.8 improved nan-proofing of softmax Fri Nov  6 12:53:16 PST 2015
    # @test isapprox(test4[1], 0.10610757f0; rtol=0.01)
    # @test isapprox(test4[2], 24.87226f0; rtol=0.001)
    # @test isapprox(test4[3], 3.3128357f0; rtol=0.1)

    # (0.109181836f0,43.36849f0,3.2359037f0) # Wed Nov 18 21:39:18 PST 2015: xavier init
    @test isapprox(test4[1], 0.109181836f0; rtol=0.01)
    @test isapprox(test4[2], 43.36849f0; rtol=0.001)
    @test isapprox(test4[3], 3.2359037f0; rtol=0.1)

    twice && (gc(); @time @show test4 = mnist2d("--xsparse --gcheck $gcheck"))
    # 12.362125 seconds (3.81 M allocations: 753.744 MB, 1.87% gc time) Tue Oct 20 19:13:25 PDT 2015
    # 11.751002 seconds (3.84 M allocations: 753.959 MB, 1.95% gc time) Mon Oct 26 11:10:17 PDT 2015: update uses axpy to scale with gclip&lr
    # 12.005169 seconds (3.95 M allocations: 761.003 MB, 1.90% gc time) Fri Nov  6 12:53:16 PST 2015: new add kernels
    # 11.939937 seconds (4.11 M allocations: 764.436 MB, 1.91% gc time) Wed Nov 18 21:28:22 PST 2015: lcn
end

if opts["all"] || opts["mnist2dxy"]
    isdefined(:mnist2d) || include("mnist2d.jl")
    @time @show test5 = mnist2d("--xsparse --ysparse --gcheck $gcheck")
    # @test isapprox(test5[1], 0.10628127f0; rtol=0.005)
    # @test isapprox(test5[2], 24.865437f0; rtol=0.002)
    # @test isapprox(test5[3], 3.5134742f0; rtol=0.02) # cannot compute csru vecnorm

    # 51a1bc1 v0.6.8 improved nan-proofing of softmax Fri Nov  6 12:53:16 PST 2015
    # @test isapprox(test5[1], 0.10610757f0; rtol=0.01)
    # @test isapprox(test5[2], 24.87226f0; rtol=0.001)
    # @test isapprox(test5[3], 3.3128357f0; rtol=0.1)

    # (0.1091015f0,43.368706f0,3.2359257f0); Wed Nov 18 21:39:18 PST 2015: xavier init
    @test isapprox(test5[1], 0.1091015f0; rtol=0.01)
    @test isapprox(test5[2], 43.368706f0; rtol=0.001)
    @test isapprox(test5[3], 3.2359257f0; rtol=0.1)

    twice && (gc(); @time @show test5 = mnist2d("--xsparse --ysparse --gcheck $gcheck"))
    # 14.077099 seconds (4.09 M allocations: 776.263 MB, 2.22% gc time) Tue Oct 20 19:11:52 PDT 2015
    # 13.320959 seconds (4.11 M allocations: 776.397 MB, 2.29% gc time) Mon Oct 26 11:10:17 PDT 2015: update uses axpy to scale with gclip&lr
    # 13.339761 seconds (4.23 M allocations: 783.602 MB, 2.27% gc time) Fri Nov  6 12:53:16 PST 2015: new add kernels
    # 13.421199 seconds (4.37 M allocations: 786.728 MB, 2.27% gc time) Wed Nov 18 21:28:22 PST 2015: lcn
end

if opts["all"] || opts["mnist4d"]
    include("mnist4d.jl")
    @time @show test6 = mnist4d("--gcheck $gcheck")

    # @test isapprox(test6[1], 0.050180204f0; rtol=.01)
    # @test isapprox(test6[2], 25.783848f0;   rtol=.01)
    # @test isapprox(test6[3], 9.420588f0;    rtol=.1)

    # 51a1bc1 v0.6.8 improved nan-proofing of softmax Fri Nov  6 12:53:16 PST 2015
    # @test isapprox(test6[1], .050181; rtol=0.01)
    # @test isapprox(test6[2], 25.7783; rtol=0.001)
    # @test isapprox(test6[3], 9.59026; rtol=0.1)

    # (0.02938571214979068,65.9176025390625,7.652309894561768); Wed Nov 18 21:39:18 PST 2015: xavier init
    @test isapprox(test6[1], .029385; rtol=0.01)
    @test isapprox(test6[2], 65.9176; rtol=0.001)
    @test isapprox(test6[3], 7.65231; rtol=0.1)

    twice && (gc(); @time @show test6 = mnist4d("--gcheck $gcheck"))
    # 17.093371 seconds (10.15 M allocations: 479.611 MB, 1.11% gc time) Tue Oct 20 19:09:19 PDT 2015
    # 17.135514 seconds (10.38 M allocations: 494.816 MB, 1.11% gc time) Fri Nov  6 12:53:16 PST 2015: new add kernels
    # 17.002958 seconds (10.58 M allocations: 499.822 MB, 1.11% gc time) Wed Nov 18 21:28:22 PST 2015: lcn
end

if opts["all"] || opts["mnistpixels"]
    include("mnistpixels.jl")

    # @time @show test7 = mnistpixels("--gcheck $gcheck")
    # 9.909841 seconds (45.76 M allocations: 1.208 GB, 3.52% gc time)
    # 8.877034 seconds (43.27 M allocations: 1.099 GB, 4.33% gc time)
    # @test test7  == (0.1216,2.3023171f0,10.4108f0,30.598776f0)
    # @test test7 == (0.12159999999999982,2.3023171f0,10.4108f0,30.598776f0) # switched to itembased
    # @test test7 == (0.12159999999999982,2.3023171f0,10.412794f0,30.598776f0) # measuring wnorm after update now

    # switch to lstm so we can gradcheck, too slow for gcheck>1
    @time @show test7 = mnistpixels("--gcheck $gcheck --nettype lstm --testfreq 2 --epochs 1 --batchsize 64 --epochsize 128") 
    @test test7 == (0,2.3025737f0,14.70776f0,0.12069904f0) # switched to --gcheck 1 --nettype lstm --testfreq 2 --epochs 1 --batchsize 64 --epochsize 128
    twice && (gc(); @time @show test7 = mnistpixels("--gcheck $gcheck --nettype lstm --testfreq 2 --epochs 1 --batchsize 64 --epochsize 128"))
    # 2.599979 seconds (5.19 M allocations: 212.248 MB, 2.77% gc time)  Tue Oct 20 19:07:11 PDT 2015
    # 2.713217 seconds (5.28 M allocations: 217.967 MB, 2.56% gc time)  Fri Nov  6 12:53:16 PST 2015: new add kernels
end

if opts["all"] || opts["addinglstm"]
    include("adding.jl")
    @time @show test8 = adding("--gcheck $gcheck --epochs 1 --nettype lstm")

    @test test8 == (0.24768005f0,3.601481f0,1.2290705f0)      # switched to --epochs 1 --nettype lstm, gradcheck does not work with irnn/relu

    twice && (gc(); @time @show test8 = adding("--gcheck $gcheck --epochs 1 --nettype lstm"))
    # 2.028728 seconds (3.82 M allocations: 164.958 MB, 1.95% gc time)  Tue Oct 20 19:03:01 PDT 2015
    # 2.246450 seconds (3.90 M allocations: 169.582 MB, 2.18% gc time)  Fri Nov  6 12:53:16 PST 2015: new add kernels
end

if opts["all"] || opts["addingirnn"]
    include("adding.jl")
    @time @show test8b = adding("--gcheck $gcheck")

    # @test test8b  == (0.04885713f0, 5.6036315f0,3.805253f0)  	# --epochs 20 --nettype irnn
    # @test test8b  == (0.04885713f0, 5.6057444f0, 3.805253f0) 	# measuring wnorm after update now
    # @test test8b == (0.05627571f0,5.484082f0,4.1594324f0)    	# new generator
    @test test8b == (0.056275677f0,5.484083f0,4.159457f0)	# 51a1bc1 v0.6.8 improved nan-proofing of softmax Fri Nov  6 12:53:16 PST 2015

    twice && (gc(); @time @show test8b = adding("--gcheck $gcheck"))
    # 9.114330 seconds (16.23 M allocations: 704.629 MB, 1.80% gc time) # --epochs 20 --nettype irnn
    # 10.703243 seconds (20.59 M allocations: 863.693 MB, 2.41% gc time) Fri Nov  6 12:53:16 PST 2015: new add kernels
    # 10.528267 seconds (21.14 M allocations: 876.542 MB, 2.01% gc time) Wed Nov 18 21:28:22 PST 2015: lcn
end

if opts["all"] || opts["rnnlm"]
    include("rnnlm.jl")
    if !isfile("ptb.valid.txt")
        info("Downloading ptb...")
	run(pipeline(`wget -q -O- http://www.fit.vutbr.cz/~imikolov/rnnlm/simple-examples.tgz`,
                     `tar --strip-components 3 -xvzf - ./simple-examples/data/ptb.valid.txt ./simple-examples/data/ptb.test.txt`))
    end
    @time @show test9 = rnnlm("ptb.valid.txt ptb.test.txt --gcheck $gcheck")

    # This is for: Float64
    # @test isapprox(test9[1], 814.9780887272417;  rtol=.0001)
    # @test isapprox(test9[2], 541.2457922913605;  rtol=.0001)
    # @test isapprox(test9[3], 267.626257438979;   rtol=.005)
    # @test isapprox(test9[4], 120.16170771885587; rtol=.0001)

    # Changing to: Float32
    # @test isapprox(test9[1], 825.336, rtol=0.05)
    # @test isapprox(test9[2], 531.640, rtol=0.05)
    # @test isapprox(test9[3], 267.337, rtol=.005)
    # @test isapprox(test9[4], 136.923, rtol=0.0001)

    # 51a1bc1 v0.6.8 improved nan-proofing of softmax Fri Nov  6 12:53:16 PST 2015
    @test isapprox(test9[1], 822.177, rtol=0.01)
    @test isapprox(test9[2], 535.746, rtol=0.1)
    @test isapprox(test9[3], 267.272, rtol=0.001)
    @test isapprox(test9[4], 136.923, rtol=0.0001)

    twice && (gc(); @time @show test9 = rnnlm("ptb.valid.txt ptb.test.txt --gcheck $gcheck"))
    # 32.368835 seconds (22.35 M allocations: 2.210 GB, 1.56% gc time)   for Float64
    # 22.892147 seconds (22.46 M allocations: 945.257 MB, 2.17% gc time) after switching to Float32
    # 21.982870 seconds (20.64 M allocations: 866.929 MB, 3.08% gc time) Tue Oct 20 19:00:29 PDT 2015
    # 22.972406 seconds (21.15 M allocations: 893.519 MB, 3.08% gc time) Fri Nov  6 12:53:16 PST 2015: new add kernels
    # 23.269379 seconds (21.74 M allocations: 902.787 MB, 3.01% gc time) Wed Nov 18 21:28:22 PST 2015: lcn
end

if opts["all"] || opts["copyseq"]
    if !isfile("ptb.valid.txt")
        info("Downloading ptb...")
	run(pipeline(`wget -q -O- http://www.fit.vutbr.cz/~imikolov/rnnlm/simple-examples.tgz`,
                     `tar --strip-components 3 -xvzf - ./simple-examples/data/ptb.valid.txt ./simple-examples/data/ptb.test.txt`))
    end
    include("copyseq.jl")
    @time @show test10 = copyseq("--epochs 1 --gcheck $gcheck ptb.valid.txt ptb.test.txt")

    # @test isapprox(test10[1], 3143.22; rtol=.001)
    # @test isapprox(test10[2], 1261.19; rtol=.0001)
    # @test isapprox(test10[3], 106.760; rtol=.0001)
    # @test isapprox(test10[4], 206.272; rtol=.0001)

    # 51a1bc1 v0.6.8 improved nan-proofing of softmax Fri Nov  6 12:53:16 PST 2015
    # @test isapprox(test10[1], 3130.86 ; rtol=.0001)
    # @test isapprox(test10[2], 1363.82 ; rtol=.0001)
    # @test isapprox(test10[3],  105.026; rtol=.0001)
    # @test isapprox(test10[4],  184.931; rtol=.0001)

    # (4248.32913889032,959.0360211411156,102.61302185058594,145.56500244140625); Wed Nov 18 21:39:18 PST 2015: xavier init
    @test isapprox(test10[1], 4248.329; rtol=.0001)
    @test isapprox(test10[2],  959.036; rtol=.0001)
    @test isapprox(test10[3],  102.613; rtol=.0001)
    @test isapprox(test10[4],  145.565; rtol=.0001)

    twice && (gc(); @time @show test10 = copyseq("--epochs 1 --gcheck $gcheck ptb.valid.txt ptb.test.txt"))
    # 5.984980 seconds (8.33 M allocations: 353.611 MB, 4.15% gc time) Tue Oct 20 18:58:25 PDT 2015
    # 11.230476 seconds (16.29 M allocations: 701.612 MB, 4.05% gc time) Wed Oct 21 23:19:24 PDT 2015 (unsorted input)
    # 11.658034 seconds (17.49 M allocations: 752.336 MB, 4.47% gc time) Fri Nov  6 12:53:16 PST 2015: new add kernels
    # 11.743344 seconds (17.82 M allocations: 749.691 MB, 4.43% gc time) Wed Nov 18 21:28:22 PST 2015: lcn
end

if opts["all"] || opts["ncelm"]
    include("ncelm.jl")
    if !isfile("ptb.valid.txt")
        info("Downloading ptb...")
	run(pipeline(`wget -q -O- http://www.fit.vutbr.cz/~imikolov/ncelm/simple-examples.tgz`,
                     `tar --strip-components 3 -xvzf - ./simple-examples/data/ptb.valid.txt ./simple-examples/data/ptb.test.txt`))
    end
    @time @show test11 = ncelm("ptb.valid.txt ptb.test.txt --gcheck $gcheck")
    @test isapprox(test11[1], 1.04277, rtol=0.0001)
    @test isapprox(test11[2], 1411.14, rtol=0.0001)
    @test isapprox(test11[3], 968.846, rtol=0.0001)
    @test isapprox(test11[4], 31.8226, rtol=0.0001)
    twice && (gc(); @time @show test11 = ncelm("ptb.valid.txt ptb.test.txt --gcheck $gcheck"))
    # 6.069526 seconds (5.36 M allocations: 204.252 MB, 2.06% gc time)
    # 6.079928 seconds (5.45 M allocations: 204.452 MB, 2.21% gc time) Wed Nov 18 21:28:22 PST 2015: lcn
end

if (opts["all"] || opts["ner"]) && isfile("ner.jld")
    include("ner.jl")
    @time @show test12 = ner("--devfortrn --epochs 1 --batchsize 128")
    @test test12 == (1,5.391641813553446,5.146268547771243,0.8020976309565352)
    twice && (gc(); @time @show test12 = ner("--devfortrn --epochs 1 --batchsize 128"))
    # 20.866555 seconds (37.80 M allocations: 1.829 GB, 6.12% gc time)
    # 20.983972 seconds (38.88 M allocations: 1.854 GB, 6.21% gc time) Wed Nov 18 21:28:22 PST 2015: lcn
end
