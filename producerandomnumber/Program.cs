using System.ComponentModel;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.UseStaticFiles();







app.MapGet("/", () =>

{

    Random random = new Random();

    List<int> randomList = new List<int>();

    while (randomList.Count < 100)
    {
        int newRandom = random.Next(100);
        if (!randomList.Contains(newRandom))
        {
            randomList.Add(newRandom);
        }
    }

    return Results.Json(new { numberFromASP = randomList[0] });

});



app.Run();






