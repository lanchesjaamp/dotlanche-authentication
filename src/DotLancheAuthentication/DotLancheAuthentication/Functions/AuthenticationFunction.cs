using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Core;
using Amazon.Lambda.Annotations.APIGateway;
using Amazon.Lambda.Annotations;
using System.Threading.Tasks;
using DotLancheAuthentication.Contracts;
using static System.Net.Mime.MediaTypeNames;

[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace DotLancheAuthentication.Functions
{
    public class AuthenticationFunction
    {
        [LambdaFunction(ResourceName = "SignIn")]
        [HttpApi(LambdaHttpMethod.Post, "/sign-in")]
        public async Task<APIGatewayProxyResponse> SignIn([FromBody] Teste request, ILambdaContext context)
        {
            var body = new { message = "SignIn successful" };
            return new APIGatewayProxyResponse()
            {
                StatusCode = 200,
                Body = ""
            };
        }

        [LambdaFunction(ResourceName = "SignUp")]
        [HttpApi(LambdaHttpMethod.Post, "/sign-up")]
        public async Task<APIGatewayProxyResponse> SignUp([FromBody] Teste request, ILambdaContext context)
        {
            var body = new { message = "SignUp successful" };
            return new APIGatewayProxyResponse()
            {
                StatusCode = 200,
                Body = ""
            };
        }

        [LambdaFunction(ResourceName = "GetUser")]
        [HttpApi(LambdaHttpMethod.Get, "/get-user/{cpf}")]
        public APIGatewayProxyResponse GetUser(string cpf, ILambdaContext context)
        {
            var body = new { message = "User information retrieved" };
            return new APIGatewayProxyResponse()
            {
                StatusCode = 200,
                Body = ""
            };
        }
    }
}
