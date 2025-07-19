import { IsEmail, IsString, IsOptional } from "class-validator";
import { ApiProperty } from "@nestjs/swagger";

export class CreateUserDto {
  @ApiProperty({ example: "john@example.com" })
  @IsEmail()
  email: string;

  @ApiProperty({ example: "John Doe", required: false })
  @IsOptional()
  @IsString()
  name?: string;
}
