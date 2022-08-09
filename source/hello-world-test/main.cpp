#include <fstream>
#include <functional>
#include <filesystem>
#include <iostream>
#include <sstream>
#include <string>

#include "version.hh"

// Testing was compiled with C++ 20.
//
// Demonstrates a simple fold expression.
//
std::string print(std::ostream& s, auto&& ... args)
{
    // Note: A 'real-life' example would need to be more robust.
    //
    //       E.g., If arg was '\n', etc. then it will be evaluated
    //             as arithmetic vs using "\n"...and so forth.
    //
    // The purpose here is to demonstrate using a lambda with
    // a fold expression.
    //
    auto format_number = [] (auto& v, int nth, const int end)
    {
        if constexpr(std::is_arithmetic_v<typename std::remove_reference<decltype(v)>::type>)
        {
            if (nth == end) return std::to_string(v);
            return std::to_string(v).append(", ");
        }
        else
            return v;
    };

	int nth{};
    constexpr auto end{ (sizeof...(args)) - 1 };

    // Return the string that is created so that may be used it again.
    //
    std::ostringstream  os;
    os << "parameter pack size: " << sizeof...(args) << "\nOutputs:\n";
	((os << format_number(args, ++nth, end)), ...);
    auto r = os.str();
    return   (s << r), r;
}

inline std::string make_log_file_name(auto&& ... args) { std::string r; (r.append(args), ...); return r; }

int main()
{
    std::string result = print(std::cout, "Hello ", "World\n", "Arithmetic: ", -2, -1, 0, 1, 1.25, 2, "\n");

    // Print it to a file.
    //
    // Name the output file based on the system it was run from:
    //
    auto ln =  make_log_file_name("./", slx::os_system_str, ".log");
    std::cout << "\nWriting " << ln << "...\n";
    std::ofstream logfile(ln);
    logfile << result;

    return std::filesystem::exists(ln) ? EXIT_SUCCESS : EXIT_FAILURE;
}
