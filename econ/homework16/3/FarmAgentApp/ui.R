shinyUI(fluidPage(
  titlePanel(h1("Agent Based Model of Farm Type Usage",align="center")),
  sidebarLayout(
    sidebarPanel(h3("Farmer Parameters"),
                 numericInput("priceSwitch",label="Cost of Switching Method",
                              value=2,min=1,max=50),
                 numericInput("pricePro",label="Price of PC Means",
                              value=10,min=1,max=50),
                 numericInput("priceNotPro",label="Price of Non-PC Means",
                              value=8,min=1,max=50),
                 numericInput("effPro",label="Percent Efficiency of PC Means",
                              value=100,min=0,max=100),
                 numericInput("effNotPro",label="Percent Efficiency of Non-PC Means",
                              value=80,min=0,max=100),
                 numericInput("nfarmersPro",label="Starting Number of PC Farmers",
                              value=50,min=1,max=100),
                 numericInput("nfarmersNotPro",label="Starting Number of Non-PC Farmers",
                              value=50,min=1,max=100),
                 h3("Consumer Parameters"),
                 numericInput("nconsumersPro",label="Starting Number of PC Consumers",
                              value=50,min=1,max=500),
                 numericInput("nconsumersNotPro",label="Starting Number of Non-PC Consumers",
                              value=50,min=1,max=500),
                 numericInput("benifitPro",label="Percent Attractiveness of PC to Consumers",
                              value=100,min=0,max=100),
                 numericInput("benifitNotPro",label="Percent Attractiveness of Non-PC to Consumers",
                              value=100,min=0,max=100),
                 h3("How many interations"),
                 numericInput("nTicks",label="Ticks",
                              value=50,min=10,max=250)
    ),
    mainPanel(h2("Popularity Output",align="center"),
              plotOutput("farmerPlot"),
              plotOutput("consumerPlot")
    )
  )
))