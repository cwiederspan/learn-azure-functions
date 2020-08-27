using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace MyFunction {

    public static class AddData {

        [FunctionName("add")]
        public static IActionResult Run(

            [HttpTrigger(AuthorizationLevel.Function, "get", Route = null)]
            HttpRequest req,

            [CosmosDB(
                databaseName: "MyDatabase",
                collectionName: "MyData",
                ConnectionStringSetting = "CosmosDBConnection"
            )]
            out dynamic document,

            ILogger log
        ) {

            log.LogInformation("C# HTTP trigger function processed a request.");

            string first = req.Query["first"];
            string last = req.Query["last"];
            string favorite = req.Query["favorite"];

            // We need both name and task parameters.
            if (!string.IsNullOrEmpty(first) && !string.IsNullOrEmpty(last)) {
                
                document = new {
                    id = System.Guid.NewGuid(),
                    firstName = first,
                    lastName = last,
                    favorite = favorite
                };

                return (ActionResult)new JsonResult(document);
            }
            else {

                document = null;
                return (ActionResult)new BadRequestResult();
            }
        }
    }
}
