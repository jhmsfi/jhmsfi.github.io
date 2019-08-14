options(shiny.maxRequestSize = 500*1024^2)

source("Agent.R")

shinyServer(function(input, output) {
  output$farmerPlot<-renderPlot({
    a<-agentFarm(priceSwitch=input$priceSwitch,pricePro=input$pricePro,
                        priceNotPro=input$priceNotPro,effPro=(input$effPro/100),
                        effNotPro=(input$effNotPro/100),benifitPro=(input$benifitPro/100),
                        benifitNotPro=(input$benifitNotPro/100),nfarmersPro=input$nfarmersPro,
                        nfarmersNotPro=input$nfarmersNotPro,nconsumersPro=input$nconsumersPro,
                        nconsumersNotPro=input$nconsumersNotPro,nTicks=input$nTicks)
plot(a[[1]],type="l",col="red",ylim=c(0,(input$nfarmersPro+input$nfarmersNotPro)),xlab="Time",ylab="Popularity",main="Farmer popularity of PC(red) vs. non-PC (blue) methods")
lines(a[[2]],col="blue")
  })
  
  output$consumerPlot<-renderPlot({
    a<-agentFarm(priceSwitch=input$priceSwitch,pricePro=input$pricePro,
                 priceNotPro=input$priceNotPro,effPro=(input$effPro/100),
                 effNotPro=(input$effNotPro/100),benifitPro=(input$benifitPro/100),
                 benifitNotPro=(input$benifitNotPro/100),nfarmersPro=input$nfarmersPro,
                 nfarmersNotPro=input$nfarmersNotPro,nconsumersPro=input$nconsumersPro,
                 nconsumersNotPro=input$nconsumersNotPro,nTicks=input$nTicks)
    plot(a[[3]],type="l",col="red",ylim=c(0,(input$nconsumersPro+input$nconsumersNotPro)),xlab="Time",ylab="Popularity",main="Consumer popularity of PC(red) vs. non-PC (blue) methods")
    lines(a[[4]],col="blue")
  })

})
