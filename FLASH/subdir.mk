################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include makefile.local

# Add inputs and outputs from these tool invocations to the build variables 
ASM_SRCS += \
../main.asm \

ASM_SRCS_QUOTED += \
"../main.asm" \

OBJS += \
./main_asm.obj \

ASM_DEPS_QUOTED += \
"./main_asm.d" \

ASM_DEPS += \
./main_asm.d \

OBJS_QUOTED += \
"./main_asm.obj" \

OBJS_OS_FORMAT += \
./main_asm.obj \


# Each subdirectory must supply rules for building sources it contributes
main_asm.obj: ../main.asm
	@echo 'Building file: $<'
	@echo 'Executing target #1 $<'
	@echo 'Invoking: HCS08 Assembler'
	"$(HC08ToolsEnv)/ahc08" -ArgFile"main.args" -Objn"./main_asm.obj" "$<" $(ASM_SRCS_QUOTED) -Lm="$(@:%.obj=%.d)" -LmCfg=xilmou
	@echo 'Finished building: $<'
	@echo ' '

main_asm.obj: main_asm.obj

main_asm.d: ../main.asm
	@echo 'Regenerating dependency file: $@'
	
	@echo ' '


