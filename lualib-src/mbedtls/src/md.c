ssorDefinitions)</PreprocessorDefinitions>
      <SDLCheck>true</SDLCheck>
      <AdditionalIncludeDirectories>..\..\..\skynet-src;..\posix</AdditionalIncludeDirectories>
    </ClCompile>
    <Link>
      <SubSystem>Windows</SubSystem>
      <GenerateDebugInformation>true</GenerateDebugInformation>
      <EnableCOMDATFolding>true</EnableCOMDATFolding>
      <OptimizeReferences>true</OptimizeReferences>
      <AdditionalLibraryDirectories>$(SolutionDir);$(SolutionDir)..\..\</AdditionalLibraryDirectories>
      <AdditionalDependencies>%(AdditionalDependencies)</AdditionalDependencies>
    </Link>
  </ItemDefinitionGroup>
  <ItemGroup>
    <ClCompile Include="..\..\..\3rd\lua\lapi.c" />
    <ClCompile Include="..\..\..\3rd\lua\lauxlib.c" />
    <ClCompile Include="..\..\..\3rd\lua\lbaselib.c" />
    <ClCompile Include="..\..\..\3rd\lua\lbitlib.c" />
    <ClCompile Include="..\..\..\3rd\lua\lcode.c" />
    <ClCompile Include="..\..\..\3rd\lua\lcorolib.c" />
    <ClCompile Include="..\..\..\3rd\lua\lctype.c" />
    <ClCompile Include="..\..\..\3rd\lua\ldblib.c" />
    <ClCompile Include="..\..\..\3rd\lua\ldebug.c" />
    <ClCompile Include="..\..\..\3rd\lua\ldo.c" />
    <ClCompile Include="..\..\..\3rd\lua\ldump.c" />
    <ClCompile Include="..\..\..\3rd\lua\lfunc.c" />
    <ClCompile Include="..\..\..\3rd\lua\lgc.c" />
    <ClCompile Include="..\..\..\3rd\lua\linit.c" />
    <ClCompile Include="..\..\..\3rd\lua\liolib.c" />
    <ClCompile Include="..\..\..\3rd\lua\llex.c" />
    <ClCompile Include="..\..\..\3rd\lua\lmathlib.c" />
    <ClCompile Include="..\..\..\3rd\lua\lmem.c" />
    <ClCompile Include="..\..\..\3rd\lua\loadlib.c" />
    <ClCompile Include="..\..\..\3rd\lua\lobject.c" />
    <ClCompile Include="..\..\..\3rd\lua\lopcodes.c" />
    <ClCompile Include="..\..\..\3rd\lua\loslib.c" />
    <ClCompile Include="..\..\..\3rd\lua\lparser.c" />
    <ClCompile Include="..\..\..\3rd\lua\lstate.c" />
    <ClCompile Include="..\..\..\3rd\lua\lstring.c" />
    <ClCompile Include="..\..\..\3rd\lua\lstrlib.c" />
    <ClCompile Include="..\..\..\3rd\lua\ltable.c" />
    <ClCompile Include="..\..\..\3rd\lua\ltablib.c" />
    <ClCompile Include="..\..\..\3rd\lua\ltm.c" />
    <ClCompile Include="..\..\..\3rd\lua\lundump.c" />
    <ClCompile Include="..\..\..\3rd\lua\lutf8lib.c" />
    <ClCompile Include="..\..\..\3rd\lua\lvm.c" />
    <ClCompile Include="..\..\..\3rd\lua\lzio.c" />
  </ItemGroup>
  <ItemGroup>
    <ClInclude Include="..\..\..\3rd\lua\lapi.h" />
    <ClInclude Include="..\..\..\3rd\lua\lauxlib.h" />
    <ClInclude Include="..\..\..\3rd\lua\lcode.h" />
    <ClInclude Include="..\..\..\3rd\lua\lctype.h" />
    <ClInclude Include="..\..\..\3rd\lua\ldebug.h" />
    <ClInclude Include="..\..\..\3rd\lua\ldo.h" />
    <ClInclude Include="..\..\..\3rd\lua\lfunc.h" />
    <ClInclude Include="..\..\..\3rd\lua\lgc.h" />
    <ClInclude Include="..\..\..\3rd\lua\llex.h" />
    <ClInclude Include="..\..\..\3rd\lua\llimits.h" />
    <ClInclude Include="..\..\..\3rd\lua\lmem.h" />
    <ClInclude Include="..\..\..\3rd\lua\lobject.h" />
    <ClInclude Include="..\..\..\3rd\lua\lopcodes.h" />
    <ClInclude Include="..\..\..\3rd\lua\lparser.h" />
    <ClInclude Include="..\..\..\3rd\lua\lprefix.h" />
    <ClInclude Include="..\..\..\3rd\lua\lstate.h" />
    <ClInclude Include="..\..\..\3rd\lua\lstring.h" />
    <ClInclude Include="..\..\..\3rd\lua\ltable.h" />
    <ClInclude Include="..\..\..\3rd\lua\ltm.h" />
    <ClInclude Include="..\..\..\3rd\lua\lua.h" />
    <ClInclude Include="..\..\..\3rd\lua\lua.hpp" />
    <ClInclude Include="..\..\..\3rd\lua\luaconf.h" />
    <ClInclude Include="..\..\..\3rd\lua\lualib.h" />
    <ClInclude Include="..\..\..\3rd\lua\lundump.h" />
    <ClInclude Include="..\..\..\3rd\lua\lvm.h" />
    <ClInclude Include="..\..\..\3rd\lua\lzio.h" />
  </ItemGroup>
  <ItemGroup>
    <ProjectReference Include="posix.vcxproj">
      <Project>{44f52237-ae31-499f-a74c-4e02b0fad898}</Project>
    </ProjectReference>
  </ItemGroup>
  <Import Project="$(VCTargetsPath)\Microsoft.Cpp.targets" />
  <ImportGroup Label="ExtensionTargets">
  </ImportGroup>
</Project>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               