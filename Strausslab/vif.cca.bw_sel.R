vif.cca.bw_sel<- function(physeq, variables, threshold=10){
   
  frm <- paste(names(variables), collapse = '+')
 
  cca_model <- ordinate(
    physeq = physeq,
    method = "CCA",
    formula = as.formula(paste('~',frm)))

  vif.cca(cca_model)
  
  vif.dat <- as.data.frame(vif.cca(cca_model))
  max_row <-which(vif.dat[,1] == max(as.numeric(vif.dat[,1]), na.rm = TRUE))[1]
  
  vif_max<-as.numeric(vif.dat[max_row,1])
  
  if(vif_max < threshold){
    cca_ord <-cca_model
    return(cca_ord)
  }else{
  
    invar <- variables
    
    while(vif_max >= threshold){
    
      if(row.names(vif.dat)[max_row] %in% names(dummy.data.frame(variables[,sapply(variables, is.factor)], sep=""))){
        for(category in names(variables[,sapply(variables, is.factor)])){
          if(row.names(vif.dat)[max_row] %in% names(dummy.data.frame(variables[category]))){
            lessvariables <- invar[,!names(invar) == category]
          }
        }
        
      }else{
        lessvariables <-invar[,!names(invar) %in% row.names(vif.dat)[max_row]]
      }    
      
      frm2 <- paste(names(lessvariables), collapse = '+')
      
      cca_ord <- ordinate(
        physeq = physeq,
        method = "CCA",
        formula = as.formula(paste('~',frm2)))
      
      vif.dat <- as.data.frame(vif.cca(cca_ord))
      
      max_row <-which(vif.dat[,1] == max(as.numeric(vif.dat[,1]), na.rm = TRUE))[1]
      
      vif_max<-as.numeric(vif.dat[max_row,1])
      
      if(vif_max < threshold) break
      
      invar <- lessvariables
      
      print(paste0("Removing variable ",rownames(vif.dat)[max_row], " with VIF:", round(vif_max,2)))
      }
  return(cca_ord)
    }
}