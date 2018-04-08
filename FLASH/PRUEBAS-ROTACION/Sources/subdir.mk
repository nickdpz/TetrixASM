################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../../makefile.local

# Add inputs and outputs from these tool invocations to the build variables 
ASM_SRCS += \
../PRUEBAS-ROTACION/Sources/main.asm \

ASM_SRCS_QUOTED += \
"../PRUEBAS-ROTACION/Sources/main.asm" \

OBJS += \
./PRUEBAS-ROTACION/Sources/main_asm.obj \

ASM_DEPS_QUOTED += \
"./PRUEBAS-ROTACION/Sources/main_asm.d" \

ASM_DEPS += \
./PRUEBAS-ROTACION/Sources/main_asm.d \

OBJS_QUOTED += \
"./PRUEBAS-ROTACION/Sources/main_asm.obj" \

OBJS_OS_FORMAT += \
./PRUEBAS-ROTACION/Sources/main_asm.obj \


# Each subdirectory must supply rules for building sources it contributes
PRUEBAS-ROTACION/Sources/main_asm.obj: ../PRUEBAS-ROTACION/Sources/main.asm
	@echo 'Building file: $<'
	@echo 'Executing target #2 $<'
	@echo 'Invoking: HCS08 Assembler'
	"$(HC08ToolsEnv)/ahc08" -ArgFile"PRUEBAS-ROTACION/Sources/main.args" -Objn"PRUEBAS-ROTACION/Sources/main_asm.obj" "$<" $(ASM_SRCS_QUOTED) -Lm="$(@:%.obj=%.d)" -LmCfg=xilmou
	@echo 'Finished building: $<'
	@echo ' '

PRUEBAS-ROTACION/Sources/main_asm.obj: PRUEBAS-ROTACION/Sources/main_asm.obj

PRUEBAS-ROTACION/Sources/%.d: ../PRUEBAS-ROTACION/Sources/%.asm
	@echo 'Regenerating dependency file: $@'
	
	@echo ' '


