import { NestFactory } from "@nestjs/core";
import { AppModule } from "./app.module";
import { ValidationPipe } from "@nestjs/common";
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // CORS設定
  const corsOrigins = process.env.NODE_ENV === 'production' 
    ? [process.env.FRONTEND_URL || 'https://your-domain.com']
    : ["http://localhost:3000"];
  
  app.enableCors({
    origin: corsOrigins,
    methods: "GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS",
    credentials: true,
  });

  // Global validation pipe
  app.useGlobalPipes(new ValidationPipe());

  // Set global prefix for API routes
  app.setGlobalPrefix('api');

  // Swagger設定
  const config = new DocumentBuilder()
    .setTitle("SDB Sample API")
    .setDescription("The SDB Sample API description")
    .setVersion("1.0")
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup("api", app, document);

  await app.listen(3001);
  console.log("Backend server is running on http://localhost:3001");
}
bootstrap();
