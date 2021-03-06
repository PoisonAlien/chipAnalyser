#' Create Pie Charts with peak annotations
#' @description Creates pie charts with peak annotations of entered files. 
#' @param p_anno File with peakID and corresponding Annotation. Default value is NULL.
#' @export

peak_annos = function(p_anno = NULL, state2color = NULL ){
  
  if(is.null(p_anno)){
    stop("no p_anno file available")
  }  
  
  
  # message("creating temporary peak annotation file...")
  # tem_pa= paste0( basename(p_anno), '.txt')
  
  message("reading peak annotation file...")
  anno = list()
  #anno[[1]] = data.table::fread(input = p_anno[[1]], header = TRUE)
  anno_s = list()
  # anno_s [[1]]= strsplit(x = anno[[1]][,Annotation], split = " ")
  # anno[[1]][,'name'] = sapply(X = anno_s[[1]], '[[',1)
  
  #if(length(p_anno) >1){
    for(i in 1:length(p_anno)){
      anno [[i]]= data.table::fread(input = p_anno[[i]], header = TRUE)
      anno_s [[i]]= strsplit(x = anno[[i]][,Annotation], split = " ")
      anno[[i]][,'name'] = sapply(X = anno_s[[i]], '[[',1)
    }
  #}
  #return(anno)
  if(!is.null(state2color)){
    seg = data.table::fread(input = state2color, header = TRUE)
    if(ncol(seg) < 3){
      colr = RColorBrewer::brewer.pal(n = 8, name = 'Dark2')
    }
    
      # for(j in 1:length(anno)){
      #   #gsub(pattern = seg[,1], replacement = seg[,2], x = anno[[j]][,'name'])
      #   anno[[j]] = merge(anno[[j]], seg[,c('name','title')], by='name')
      # }
    message("count annotation frequency and order them...")
    pa = list()
    for(i in 1:length(p_anno)){
      pa[[i]] = anno[[i]][,.N, name]
      pa[[i]] = merge(pa[[i]], seg[,c('name','color')], by='name')
      pa[[i]] = merge(pa[[i]], seg[,c('name','title')], by='name')
      pa[[i]] = pa [[i]][order(pa[[i]][,2]),]
      pa[[i]][,'pct'] = round(pa[[i]][,'N']/sum(pa[[i]][,'N'])*100,digits = 2) 
      colnames(pa[[i]]) = c('or_name', 'N', 'color', 'name', 'pct')
    }
    
    names(pa) = basename(p_anno)
    
    message("creating pie chart...")
    mat.lo = matrix(data = c(1:length(pa)), byrow = TRUE, nrow = length(pa)) ### layout
    layout(mat = mat.lo, heights =  c(5, 5, 5))
    par(mar=c(1,1,1,1))
    lapply(1:length(pa), function(x){
      pie(x = pa[[x]][,N], labels =paste(pa[[x]][,name], "( N=",pa[[x]][,N],",", pa[[x]][,pct],"%)") , main = paste("Peak Annotations of ", names(pa[x])),
          col = pa[[x]][,color] , density = 60, init.angle = 180, border = "grey60", clockwise = FALSE, cex =0.6, cex.main=1)
    })
    message("Pie chart done.")
    
  }else{
    colr = RColorBrewer::brewer.pal(n = 8, name = 'Dark2')
  
 
  message("count annotation frequency and order them...")
  pa = list()
  for(i in 1:length(p_anno)){
    pa[[i]] = anno[[i]][,.N, name]
    pa[[i]] = pa [[i]][order(pa[[i]][,2]),]
    pa[[i]][,'pct'] = round(pa[[i]][,'N']/sum(pa[[i]][,'N'])*100,digits = 2) 
  }
  names(pa) = basename(p_anno)
  message("creating pie chart...")
  mat.lo = matrix(data = c(1:length(pa)), byrow = TRUE, nrow = length(pa)) ### layout
  layout(mat = mat.lo, heights =  c(5, 5, 5))
  par(mar=c(1,1,1,1))
  lapply(1:length(pa), function(x){
    pie(x = pa[[x]][,N], labels =paste(pa[[x]][,name], "( N=",pa[[x]][,N],",", pa[[x]][,pct],"%)") , main = paste("Peak Annotations of ", names(pa[x])),
    col = colr , density = 60, init.angle = 180, border = "grey60", clockwise = FALSE, cex =0.6, cex.main=1)
  })
    message("Pie chart done.")
  }
}      
