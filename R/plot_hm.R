#' Plot a heatmap of ordered (and clustered) data in mat.
#' @description Takes entered list with matrices and passes it to "tidy_mat"-function and then to the functions "get_avg", "get_xavg" or "k_means" according to the entered values for clusterBy and k_num. Matrices will be ordered and then plotted with base graphics.
#' @param mat A list with matrices and additional information about the selected region. mat generated by "get_matrix"-function. Default value is NULL.
#' @param clusterBy Integer which specifies the matrix to which all matrices will be ordered. Default value is 'avg'.
#' @param num_k Integer which specifies the number of clusters which should be build by "kmeans"-function. Default value is NULL.
#' @export

plot_hm = function(mat = NULL, clusterBy = 'avg', num_k = NULL){
  ########## check mat input (got from "get_matrix" function) ##########
  if(is.null(mat)){
    stop("no mat available")
  }
  ########## check entered options ##########
  if (clusterBy == 'avg' & !is.null(num_k)){
    stop("Entered options clusterBy = 'avg' and numeric num_k is not possible")
  }
  nmats = length(mat)-5 ### number of matrices/ inserted bw-files
  if(is.numeric(clusterBy) & clusterBy>nmats){
    stop("Entered option for clusterBy is not possible")
  }
  ########## remove duplicated rows in the matrices and rows with "NA" inside ##########
  mat = tidy_mat(ugmat = mat)
  ########## use get_avg or get_xavg function depending on inserted clusterBy input ##########
  if(clusterBy== 'avg'){
    matavg = get_avg(mat = mat)
  } else{
    if(is.numeric(clusterBy)){
     matavg = get_xavg(mat = mat, clusterBy = clusterBy)
    }
  }
  ########## use k_means function if num_k is inserted ##########
  if(!is.null(num_k)){
    mat.profile = k_means(mat = mat, refmat = clusterBy, k = num_k)
  }
  ########## profile plotting if k_means function was selected ##########
  if(!is.null(num_k)){
    
    hm.col =  RColorBrewer::brewer.pal(n = 9, name = 'Blues')[3:9] ### heatmap colors
    mat.lo = matrix(data = c(1:(nmats), (nmats)+(1:(nmats))), byrow = TRUE, nrow = 2, ncol = nmats) ### layout
    #mat.lo = matrix(data = c(1:(nmats+1), (nmats+1)+(1:(nmats+1))), byrow = TRUE, nrow = 2, ncol = nmats+1) ### layout
    layout(mat = mat.lo, heights = c(2, 8))

    matAvg = mat.profile[[1]] ### matrices for heatmap plotting
    cmats = ncol(matAvg[[1]][1]) ### number of columns in a matrix
    for (i in 1:length(matAvg)){ ### remove cluster column
      matAvg[[i]] = matAvg[[i]][,1:(cmats-1)]
    }
    matAvg = c( matAvg, mat.profile[[5]]) ### add information to matrices for heatmap plotting
    
    mat_prof = mat.profile[[2]] ### matrices for profile plotting
    
    ### profile plotting for different clusters of each matrix ###
    yls = c(0, round(max(unlist(mat_prof), na.rm = TRUE), digits = 2))
    lapply(mat_prof, function(x){
      #yls = c(0, round(max(unlist(x), na.rm = TRUE), digits = 2))
      par(mar = c(1,4,4,1))
  plot(x$'1',xlab = '', ylab =  "RPM", axes = FALSE, pch = 16, cex = 1 , las = 1, type = "l", col = 1, ylim = yls, cex.lab = 1, font.lab=2, lwd= 2)
      if(length(x) > 1){
        for(i in 2:length(x)){
          points(x[[i]], pch = 16, cex = 0.8 , las = 1, type = "l", col = i, lwd = 2)
          graphics::axis( side = 2, at = yls, labels = yls, las= 1, cex.axis = 1, font = 2, lwd = 2)
        }
      }
    })
    #plot.new()
  ### information for abline plotting ###
    cuts = mat.profile[[3]]
    cutsum = mat.profile[[4]]
    
  }else{
    # hm.col =  RColorBrewer::brewer.pal(n = 9, name = 'Blues')[3:9] ### heatmap colors
    # mat.lo = matrix(data = 1:nmats, nrow = 1, ncol = nmats) ### layout
    # layout(mat = mat.lo)
    hm.col =  RColorBrewer::brewer.pal(n = 9, name = 'Blues')[3:9] ### heatmap colors
    mat.lo = matrix(data = c(1:(nmats), (nmats)+(1:(nmats))), byrow = TRUE, nrow = 2, ncol = nmats) ### layout
    #mat.lo = matrix(data = c(1:(nmats+1), (nmats+1)+(1:(nmats+1))), byrow = TRUE, nrow = 2, ncol = nmats+1) ### layout
    layout(mat = mat.lo, heights = c(2, 8))
    
    mat_prof = matavg[[2]] ### matrices for profile plotting
    yls = c(0, round(max(unlist(mat_prof), na.rm = TRUE), digits = 2))
    lapply(mat_prof, function(x){
      #yls = c(0, round(max(unlist(x), na.rm = TRUE), digits = 2))
      par(mar = c(1,4,4,1))
      plot(x,xlab = '', ylab =  "RPM", axes = FALSE, pch = 16, cex = 1 , las = 1, type = "l", col = 1, ylim = yls, cex.lab = 1, font.lab=2, lwd = 2)
      graphics::axis( side = 2, at = yls, labels = yls, las= 1, cex.axis = 1, font = 2, lwd = 2)    
    })  
    matAvg = matavg[[1]]
    #plot.new()
  }
 
  ########## P L O T T I N G ##########
  ########## create heatmap ##########
  
  for(i in 1:nmats){
    x = matAvg[[i]][,7:(ncol(matAvg[[i]])-1), with  = FALSE]
    n = ncol(x)
    x = t(scale(x = t(x)))
    par(mar = c(8,4,4,1),xpd = NA) ### set the margin
    image(x = t(as.matrix(x)), col = hm.col, axes = FALSE)
    axis(side = 1, at = c(0, 1), labels = c(-matAvg$region[1], matAvg$region[2]), cex.axis = 0.9, line = 1, font = 2, lwd = 2)
    mtext(text = paste("region around peak [bp]"), side = 1, line = 3, cex = 0.7, font = 2 )
    title(main = names(matAvg[i]), adj = 0, cex.main = 0.9, line = 1)
        if(!is.null(num_k)){
        polygon(x = c(0,1,1,0), y = c(0,0,(cuts[[1]]-1)/cutsum,(cuts[[1]]-1)/cutsum),col = 'black', density = 0, lwd = 2)
        for (j in 1:(length(cuts)-1)) {
          polygon(x = c(0,1,1,0), y = c(cuts[[j]]/cutsum,cuts[[j]]/cutsum,(cuts[[j+1]])/cutsum,(cuts[[j+1]]-1)/cutsum),col = j+1, density = 0, lwd = 2)
          #segments(x0 = 0, x1 = 1, y0 = cuts[[j]]/cutsum, y1 = cuts[[y]]/cutsum, col= j)
          #abline(h = (cuts[[j]]/cutsum), col = j, lwd = 2)
        }
        polygon(x = c(0,1,1,0), y = c(cuts[[length(cuts)]]/cutsum,cuts[[length(cuts)]]/cutsum,1,1),col = length(cuts), density = 0, lwd=2)
        
      mtext(text = "cluster", side = 2, line = 2, font = 2, cex = 0.8)
      
      legendt = c()
      #for(i in 1:nmats){
        for (j in 1:length(mat_prof[[1]])) {
          legendt = c(legendt, paste0('cluster',j))
          #legendt = c(legendt, paste0(names(mat_prof[i]),'_cluster',j))
        }
      #}
      #legend( 'right', inset=c(-0.7,0), bty = "n", 'right', legend= legendt, col = c(1:length(mat_prof[[1]])), lty = 1, cex = 0.8)
      #legend( "bottom", inset=c(-0.7,0), bty = "n",horiz = TRUE, xpd = TRUE, legend= legendt, col = c(1:length(mat_prof[[1]])), lty = 1, cex = 0.8)    
    }
    #image(y = 1:ncol(x)-.5, x = 1:nrow(x) ,z = matrix(1:, ncol = 8), col = hm.col, add=TRUE)
  }
  
  par(fig = c(0, 1, 0, 1), oma = c(0, 0, 0, 0), mar = c(0, 0, 0, 0), new = TRUE)
  plot(0, 0, type = "n", bty = "n", xaxt = "n", yaxt = "n")
  #mtext(text = "Analysis ",side = 3, outer = TRUE, cex = 1.5, line = -2, font = 2)
  #image(x=rep(n,2)+c(2,3)+1, y=(3:4) -0.5, z=matrix(1), col=hm.col, add=TRUE)
  
  
  if(!is.null(num_k)){
  legend("bottom", legend= legendt, xpd = TRUE, horiz = TRUE, inset = c(0, 0), bty = "n", col = c(1:length(mat_prof[[1]])),lty = 1,  cex = 1, lwd = 2, text.font = 2)
  } 
  
  #image(y = c(1+ (c(-0.5, 0.5))), x = rep(7) ,z = matrix(1:7, nrow = 7), col = c("red","blue"), add=TRUE)
}
