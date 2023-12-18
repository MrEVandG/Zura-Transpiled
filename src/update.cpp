#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <sys/stat.h>
#include <unistd.h>

std::string getTag() {
    std::string osName = "unknown";
#if defined(_WIN32)
    osName = "windows";
#elif defined(__linux__)
    osName = "linux";
#elif defined(__APPLE__)
    osName = "darwin";
#endif

    if (osName == "linux" || osName == "darwin") {
        try {
            std::string result;
            FILE *pipe = popen("curl -s 'https://api.github.com/repos/TheDevConnor/Zura-Transpiled/releases'", "r");
            if (!pipe) {
                throw std::runtime_error("popen() failed");
            }

            char buffer[128];
            while (!feof(pipe)) {
                if (fgets(buffer, 128, pipe) != nullptr) {
                    result += buffer;
                }
            }

            pclose(pipe);

            std::string tag = result.substr(result.find("tag_name") + 11);
            tag = tag.substr(0, tag.find(",") - 1);
            tag = tag.substr(1);

            return tag;
        } catch (const std::exception &e) {
            std::cerr << "Error: " << e.what() << std::endl;
            return "";
        }
    } else {
        try {
            std::string result;
            std::string command = "powershell -Command \"(Invoke-RestMethod -Uri 'https://api.github.com/repos/TheDevConnor/Zura-Transpiled/releases').tag_name\"";
            FILE *pipe = popen(command.c_str(), "r");
            if (!pipe) {
                throw std::runtime_error("popen() failed");
            }

            char buffer[128];
            while (!feof(pipe)) {
                if (fgets(buffer, 128, pipe) != nullptr) {
                    result += buffer;
                }
            }

            pclose(pipe);

            std::string tag = result.substr(result.find("tag_name") + 11);
            tag = tag.substr(0, tag.find(",") - 1);
            tag = tag.substr(1);

            return tag;
        } catch (const std::exception &e) {
            std::cerr << "Error: " << e.what() << std::endl;
            return "";
        }
      return "";
    }
}

void installer() {
    std::string osName = "unknown";
#if defined(_WIN32)
    osName = "windows";
#elif defined(__linux__)
    osName = "linux";
#elif defined(__APPLE__)
    osName = "darwin";
#endif

    std::string tag = getTag();

    if (osName == "windows") {
        std::string url = "https://github.com/TheDevConnor/Zura-Transpiled/releases/download/" + tag + "/zura.exe";
        std::string command = "powershell -Command \"Invoke-WebRequest " + url + "\"";
        try {
            system(command.c_str());
            system("move zura.exe C:\\Windows\\System32");
        } catch (const std::exception &e) {
            std::cerr << "Error running command: " << e.what() << std::endl;
        }
    } else if (osName == "linux" || osName == "darwin") {
        std::string url = "https://github.com/TheDevConnor/Zura-Transpiled/releases/download/" + tag + "/zura";
        std::string command = "wget " + url;
        try {
            system(command.c_str());
            system("chmod +x zura");
            system("sudo mv zura /usr/local/bin");
        } catch (const std::exception &e) {
            std::cerr << "Error running command: " << e.what() << std::endl;
        }
    }
}
