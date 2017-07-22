﻿<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" ToolsVersion="12.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemGroup Label="ProjectConfigurations">
    <ProjectConfiguration Include="Debug|Win32">
      <Configuration>Debug</Configuration>
      <Platform>Win32</Platform>
    </ProjectConfiguration>
    <ProjectConfiguration Include="Release|Win32">
      <Configuration>Release</Configuration>
      <Platform>Win32</Platform>
    </ProjectConfiguration>
  </ItemGroup>
  <ItemGroup>
    <ClCompile Include="..\..\..\3rd\lua-md5\compat-5.2.c" />
    <ClCompile Include="..\..\..\3rd\lua-md5\md5.c" />
    <ClCompile Include="..\..\..\3rd\lua-md5\md5lib.c" />
  </ItemGroup>
  <ItemGroup>
    <ClInclude Include="..\..\..\3rd\lua-md5\compat-5.2.h" />
    <ClInclude Include="..\..\..\3rd\lua-md5\md5.h" />
  </ItemGroup>
  <ItemGroup>
    <ProjectReference Include="lua53.vcxproj">
      <Project>{2ff46585-569f-4371-85ee-55e41fd38e8b}</Project>
    </ProjectReference>
  </ItemGroup>
  <ItemGroup>
    <None Include="md5.def" />
  </ItemGroup>
  <PropertyGroup Label="Globals">
    <ProjectGuid>{C00991CA-E0D6-4D47-9898-75060B7FEE92}</ProjectGuid>
    <Keyword>Win32Proj</Keyword>
    <RootNamespace>lua53</RootNamespace>
  </PropertyGroup>
  <Import Project="$(VCTargetsPath)\Microsoft.Cpp.Default.props" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
    <ConfigurationType>DynamicLibrary</ConfigurationType>
    <UseDebugLibraries>true</UseDebugLibraries>
    <PlatformToolset>v120</PlatformToolset>
    <CharacterSet>Unicode</CharacterSet>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'" Label="Configuration">
    <ConfigurationType>DynamicLibrary</ConfigurationType>
    <UseDebugLibraries>false</UseDebugLibraries>
    <PlatformToolset>v120</PlatformToolset>
    <WholeProgramOptimization>true</WholeProgramOptimization>
    <CharacterSet>Unicode</CharacterSet>
  </PropertyGroup>
  <Import Project="$(VCTargetsPath)\Microsoft.Cpp.props" />
  <ImportGroup Label="ExtensionSettings">
  </ImportGroup>
  <ImportGroup Label="PropertySheets" Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
    <Import Project="$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props" Condition="exists('$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props')" Label="LocalAppDataPlatform" />
  </ImportGroup>
  <ImportGroup Label="PropertySheets" Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">
    <Import Project="$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props" Condition="exists('$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props')" Label="LocalAppDataPlatform" />
  </ImportGroup>
  <PropertyGroup Label="UserMacros" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
    <LinkIncremental>true</LinkIncremental>
    <IntDir>..\output\$(ProjectName)\$(Configuration)\</IntDir>
    <OutDir>$(SolutionDir)..\..\luaclib\</OutDir>
    <TargetExt>.so</TargetExt>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">
    <LinkIncremental>false</LinkIncremental>
    <IntDir>..\output\$(ProjectName)\$(Configuration)\</IntDir>
    <OutDir>$(SolutionDir)..\..\luaclib\</OutDir>
    <TargetExt>.so</TargetExt>
  </PropertyGroup>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
    <ClCompile>
      <PrecompiledHeader>
      </PrecompiledHeader>
      <WarningLevel>Level3</WarningLevel>
      <Optimization>Disabled</Optimization>
      <PreprocessorDefinitions>WIN32;LUA_BUILD_AS_DLL;_DEBUG;_WINDOWS;_USRDLL;LUA53_EXPORTS;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <SDLCheck>true</SDLCheck>
      <AdditionalIncludeDirectories>..\..\..\3rd\lua;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
    </ClCompile>
    <Link>
      <SubSystem>Windows</SubSystem>
      <GenerateDebugInformation>true</GenerateDebugInformation>
      <AdditionalLibraryDirectories>$(SolutionDir);$(SolutionDir)..\..\</AdditionalLibraryDirectories>
      <AdditionalDependencies>%(AdditionalDependencies)</AdditionalDependencies>
      <ModuleDefinitionFile>$(ProjectDir)$(ProjectName).def</ModuleDefinitionFile>
    </Link>
  </ItemDefinitionGroup>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">
    <ClCompile>
      <WarningLevel>Level3</WarningLevel>
      <PrecompiledHeader>
      </PrecompiledHeader>
      <Optimization>MaxSpeed</Optimization>
      <FunctionLevelLinking>true</FunctionLevelLinking>
      <IntrinsicFunctions>true</IntrinsicFunctions>
      <PreprocessorDefinitions>WIN32;LUA_BUILD_AS_DLL;NDEBUG;_WINDOWS;_USRDLL;LUA53_EXPORTS;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <SDLCheck>true</SDLCheck>
      <AdditionalIncludeDirectories>..\..\..\3rd\lua;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
    </ClCompile>
    <Link>
      <SubSystem>Windows</SubSystem>
      <GenerateDebugInformation>true</GenerateDebugInformation>
      <EnableCOMDATFolding>true</EnableCOMDATFolding>
      <OptimizeReferences>true</OptimizeReferences>
      <AdditionalLibraryDirectories>$(SolutionDir);$(SolutionDir)..\..\</AdditionalLibraryDirectories>
      <AdditionalDependencies>%(AdditionalDependencies)</AdditionalDependencies>
      <ModuleDefinitionFile>$(ProjectDir)$(ProjectName).def</ModuleDefinitionFile>
    </Link>
  </ItemDefinitionGroup>
  <Import Project="$(VCTargetsPath)\Microsoft.Cpp.targets" />
  <ImportGroup Label="ExtensionTargets">
  </ImportGroup>
</Project>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       