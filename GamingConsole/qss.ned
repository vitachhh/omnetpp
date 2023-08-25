package neznamvise.simulations;

import inet.node.base.GamingApp;


simple QSS extends GamingApp
{
    parameters: 
        double connectionTimeout = default(5);  
        int maxRetries = default(3);  
        double pingInterval = default(1);  
        double gameUpdateInterval = default(0.1);  
        double maxInputDelay = default(0.05);
        
        bool useQSS = default(true);
        int maxQSSIterations = default(100);
        double qssTolerance = default(1e-6);
        
      
}


