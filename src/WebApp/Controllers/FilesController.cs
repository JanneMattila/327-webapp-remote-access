using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Threading.Tasks;

namespace WebApp.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class FilesController : ControllerBase
    {
        private readonly ILogger<FilesController> _logger;

        public FilesController(ILogger<FilesController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public async Task<string> Get()
        {
            var content = "No content";
            const string exampleFile = "example.txt";

            if (System.IO.File.Exists(exampleFile))
            {
                content = await System.IO.File.ReadAllTextAsync(exampleFile);
            }
            return content;
        }
    }
}
