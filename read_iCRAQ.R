read_iCRAQ <- function(fname) {
  if (missing(fname) & .Platform$OS.type == "windows") {
    fname <- choose.files()
  }
  else if (missing(fname) & .Platform$OS.type != "windows") {
    stop("Choose.files() is windows specific !\n")
  }
  library(readr)
  for (f in fname) {
    #Load data traitement and control
    data <- read_csv(f)
    samplename <-
      readline(prompt = paste(basename(f), "Samplename: "))
    #The Idx model is Nuc_XXX for nucleus, Nuc_XXX_Chr_XXX for chromocenter and Nuc_XXX_Chr_sum for the chromocenter combination
    test <- sapply(data$Idx, function(x)
      strsplit(x, "_"))
    nuc <- sapply(test, function(x)
      length(x) < 3)
    chr <- sapply(test, function(x)
      length(x) > 2)
    chrsum <- sapply(test, function(x)
      x[4] == "sum")
    #NA are generated for nucleus
    chrsum[is.na(chrsum)] <- FALSE
    #Here put the disered condition on nucleus or chromocenter descriptors
    keep <- rep(TRUE, length(nuc)) #keep all nucleus
    idx <- 1:length(nuc) #to keep track of idx
    #Compte the number of chromocenter for each nucleus
    chrnumber <- rep(0, length(nuc))
    chrnumberkept <- rep(0, length(nuc))
    #Use this loop to adjust chromocenter position from nucleus
    xchr <- data$X
    ychr <- data$Y
    i <- 1
    while (i <= length(nuc)) {
      if (nuc[i]) {
        xnuc <- xchr[i]
        ynuc <- ychr[i]
        i <- i + 1
        cpt <- 0
        while (chr[i + cpt] &&
               !chrsum[i + cpt] &&
               !nuc[i + cpt] && i + cpt < length(nuc)) {
          #Here put condition on chromocenter that need to be considered and keep track of removed chromocenters
          keep[i + cpt] <-
            TRUE #data$Mean[i+cpt] >= data$Mean[i-1]+2*data$StdDev[i-1] #1.5*IQR/2 ~ sigma
          xchr[i + cpt] <- xchr[i + cpt] - xnuc
          ychr[i + cpt] <- ychr[i + cpt] - ynuc
          cpt <- cpt + 1
        }
        chrnumber[i - 1] <- cpt
        chrnumberkept[i - 1] <-
          cpt - sum(!keep[i:(i + cpt - 1)]) #Don't forget to remove undesired chromocenter from the count
        if (cpt > 1) {
          #If chromocenter is removed we also need to removed it from IntDen and Area of the sum for RHF and RAF computation
          #Note that we can't use StdDev of the sum of chromocenter anymore
          if (chrsum[i + cpt]) {
            #Just to check this should allways be the case !
            if (chrnumberkept[i - 1] != 0) {
              data$Area[i + cpt] <-
                sum(data$Area[idx[keep & idx < i + cpt & idx > i]])
              data$IntDen[i + cpt] <-
                sum(data$IntDen[idx[keep &
                                      idx < i + cpt & idx > i]])
              data$Mean[i + cpt] <-
                mean(data$Mean[idx[keep & idx < i + cpt & idx > i]])
            }
            else{
              keep[i + cpt] <- FALSE
            } #Remove the sum
          }
          else{
            stop("File parsed is miss constructed")
          }
          i <- i + cpt + 1
        }
        else if (cpt == 1) {
          i <- i + 1
        }
      }
      else{
        i <- i + 1
      }
    }
    #Get Nucleus with only one chromocenter
    onecc <- rep(FALSE, length(nuc))
    onecc[which(chrnumber == 1) + 1] <- TRUE
    #Compute RHF
    rhf <- rep(NA, sum(nuc & keep))
    rhf[chrnumberkept[nuc &
                        keep] != 0] <-
      100 * data$IntDen[keep &
                          (chrsum |
                             onecc)] / data$IntDen[nuc &
                                                     keep &
                                                     chrnumberkept > 0]
    #Area of nucleus occupied by chromocenter
    raf <- rep(NA, sum(nuc & keep))
    raf[chrnumberkept[nuc &
                        keep] != 0] <-
      100 * data$Area[keep &
                        (chrsum |
                           onecc)] / data$Area[nuc &
                                                 keep &
                                                 chrnumberkept > 0]
    #Chromocenter number
    cc <- chrnumberkept[nuc & keep]
    #nucleus area
    nucarea <- data$Area[nuc & keep]
    #chromocenter mean
    chrmean <- rep(NA, sum(nuc & keep))
    chrmean[chrnumberkept[nuc &
                            keep] != 0] <-
      data$Mean[keep & (chrsum | onecc)]
    #chromocenter std
    chrsd <- rep(NA, sum(nuc & keep))
    chrsd[chrnumberkept[nuc &
                          keep] != 0] <-
      data$StdDev[keep & (chrsum | onecc)]
    #nucleus circularity
    nuccirc <- data$Circ.[nuc & keep]
    #nucleus aspect ratio
    nucar <- data$AR[nuc & keep]
    #nucleus mean
    nucmean <- data$Mean[nuc & keep]
    #nucleus std
    nucsd <- data$StdDev[nuc & keep]
    #chromocenter area
    chrarea <- data$Area[keep & (chr & !chrsum)]
    #chromocenter circularity
    chrcirc <- data$Circ.[keep & (chr & !chrsum)]
    #chromocenter aspect ratio
    chrar <- data$AR[keep & (chr & !chrsum)]
    #chromocenter distance to nucleus barycenter
    chrdist <-
      sqrt(xchr[keep & (chr & !chrsum)] ^ 2 + ychr[keep & (chr &
                                                             !chrsum)] ^ 2)
    if (f == fname[1]) {
      #Nucleus data
      datanuc <-
        data.frame(
          sample = rep(samplename, length(cc)),
          cc = cc,
          rhf = rhf,
          raf = raf,
          area = nucarea,
          circ = nuccirc,
          ar = nucar,
          meannuc = nucmean,
          sdnuc = nucsd,
          meanchr = chrmean,
          sdchr = chrsd
        )
      #Chromocenter data
      datachr <-
        data.frame(
          sample = rep(samplename, length(chrarea)),
          area = chrarea,
          circ = chrcirc,
          ar = chrar,
          dst = chrdist
        )
    }
    else{
      #Nucleus data
      temp <-
        data.frame(
          sample = rep(samplename, length(cc)),
          cc = cc,
          rhf = rhf,
          raf = raf,
          area = nucarea,
          circ = nuccirc,
          ar = nucar,
          meannuc = nucmean,
          sdnuc = nucsd,
          meanchr = chrmean,
          sdchr = chrsd
        )
      datanuc <- rbind(datanuc, temp)
      #Chromocenter data
      temp <-
        data.frame(
          sample = rep(samplename, length(chrarea)),
          area = chrarea,
          circ = chrcirc,
          ar = chrar,
          dst = chrdist
        )
      datachr <- rbind(datachr, temp)
    }
  }
  return(list(datanuc, datachr))
}
