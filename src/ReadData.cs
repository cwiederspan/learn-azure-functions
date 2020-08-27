using System;
using System.IO;
using System.Threading.Tasks;
using System.Collections.Generic;

using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

using Newtonsoft.Json;

namespace Helloworld {

    public static class ReadData {

        [FunctionName("read")]
        public static IActionResult Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = null)] HttpRequest req,

            [CosmosDB(
                databaseName: "MyDatabase",
                collectionName: "MyData",
                ConnectionStringSetting = "CosmosDBConnection"
            )]
            IEnumerable<dynamic> items,

            ILogger log
        ) {

            log.LogInformation("C# HTTP trigger function processed a request.");

            return new JsonResult(items);
        }
    }
}
