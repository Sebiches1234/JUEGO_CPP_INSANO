#include <allegro5/allegro.h>
#include <allegro5/allegro_image.h>
#include <allegro5/allegro_audio.h>
#include <allegro5/allegro_acodec.h>
#include <iostream>
#include <vector>

// Define sprite size constants based on calculations
const int SPRITE_W = 48;
const int SPRITE_H = 96;

// Struct to store grid index locations for animations
struct Frame {
    int col;
    int row;
};

int main()
{
    al_init();
    al_install_keyboard();
    al_init_image_addon();
    al_install_audio();
    al_init_acodec_addon();
    al_reserve_samples(16);

    al_set_new_display_flags(ALLEGRO_OPENGL);
    ALLEGRO_DISPLAY* ventana = al_create_display(800, 600);

    if (!ventana)
        return 1;

    ALLEGRO_EVENT_QUEUE* cola = al_create_event_queue();
    al_register_event_source(cola, al_get_display_event_source(ventana));

    ALLEGRO_BITMAP* fondo = al_load_bitmap("fondo.png");
    // Changed to use your requested warrior spritesheet
    ALLEGRO_BITMAP* jugador_sheet = al_load_bitmap("warrior_sheet.png");

    if (!fondo || !jugador_sheet)
    {
        std::cout << "Error cargando imagenes\n";
        return 1;
    }

    ALLEGRO_SAMPLE* musica = al_load_sample("loop.wav");
    if (!musica)
    {
        std::cout << "No se pudo cargar loop.wav\n";
        return 1;
    }

    al_play_sample(musica, 1.0, 0.0, 1.0, ALLEGRO_PLAYMODE_LOOP, NULL);

    // Hardcoded animation frame sequences mapped from sprites.txt
    std::vector<Frame> anim_lookdown  = { {0, 0} };
    std::vector<Frame> anim_lookleft  = { {0, 1} };
    std::vector<Frame> anim_lookright = { {0, 2} };
    std::vector<Frame> anim_lookup    = { {0, 3} };

    std::vector<Frame> anim_walkdown  = { {3, 0}, {4, 0}, {5, 0}, {4, 0} };
    std::vector<Frame> anim_walkleft  = { {3, 1}, {4, 1}, {5, 1}, {4, 1} };
    std::vector<Frame> anim_walkright = { {3, 2}, {4, 2}, {5, 2}, {4, 2} };
    std::vector<Frame> anim_walkup    = { {3, 3}, {4, 3}, {5, 3}, {4, 3} };

    // Set pointer to the active animation sequence
    std::vector<Frame>* current_anim = &anim_lookdown;

    float x = 400, y = 300;
    bool salir = false;

    // Variables to manage animation timing
    float frame_timer = 0;
    int current_frame_index = 0;
    const float ANIM_SPEED = 0.15f; // Seconds per frame (~6.6 frames per second)

    while (!salir)
    {
        ALLEGRO_EVENT evento;
        while (al_get_next_event(cola, &evento))
        {
            if (evento.type == ALLEGRO_EVENT_DISPLAY_CLOSE)
                salir = true;
        }

        ALLEGRO_KEYBOARD_STATE teclado;
        al_get_keyboard_state(&teclado);

        if (al_key_down(&teclado, ALLEGRO_KEY_ESCAPE))
            salir = true;

        bool moviendose = false;
        std::vector<Frame>* next_anim = current_anim;

        // Process movement inputs and map to the corresponding animation vector
        if (al_key_down(&teclado, ALLEGRO_KEY_W)) { y -= 5; next_anim = &anim_walkup;    moviendose = true; }
        if (al_key_down(&teclado, ALLEGRO_KEY_S)) { y += 5; next_anim = &anim_walkdown;  moviendose = true; }
        if (al_key_down(&teclado, ALLEGRO_KEY_A)) { x -= 5; next_anim = &anim_walkleft;  moviendose = true; }
        if (al_key_down(&teclado, ALLEGRO_KEY_D)) { x += 5; next_anim = &anim_walkright; moviendose = true; }

        // If not pressing keys, switch to static look-direction states
        if (!moviendose) {
            if (current_anim == &anim_walkup)    next_anim = &anim_lookup;
            if (current_anim == &anim_walkdown)  next_anim = &anim_lookdown;
            if (current_anim == &anim_walkleft)  next_anim = &anim_lookleft;
            if (current_anim == &anim_walkright) next_anim = &anim_lookright;
        }

        // If the animation state changed, reset our tracking parameters
        if (next_anim != current_anim) {
            current_anim = next_anim;
            current_frame_index = 0;
            frame_timer = 0;
        }

        // Advance animation logic based on Delta Time (1/60th second frame lock)
        if (moviendose) {
            frame_timer += (1.0f / 60.0f);
            if (frame_timer >= ANIM_SPEED) {
                frame_timer = 0;
                current_frame_index = (current_frame_index + 1) % current_anim->size();
            }
        } else {
            current_frame_index = 0; // Lock to first frame if idle
        }

        al_clear_to_color(al_map_rgb(0,0,0));

        // Draw background
        al_draw_scaled_bitmap(
            fondo, 0, 0, al_get_bitmap_width(fondo), al_get_bitmap_height(fondo),
            0, 0, 800, 600, 0
        );

        // Fetch current active column and row from the sequence
        Frame frame_actual = (*current_anim)[current_frame_index];

        // Math translates grid location into raw source pixels
        int source_x = frame_actual.col * SPRITE_W;
        int source_y = frame_actual.row * SPRITE_H;

        // Render target sprite segment from sheet onto screen
        al_draw_scaled_bitmap(
            jugador_sheet,
            source_x, source_y,  // Source top-left coordinate from sheet
            SPRITE_W, SPRITE_H,  // Source size (48x96)
            x, y,                // Destination position
            48, 96,              // Target size (Drawn at actual scale ratio)
            0
        );

        al_flip_display();
        al_rest(1.0 / 60.0);
    }

    al_destroy_sample(musica);
    al_destroy_bitmap(fondo);
    al_destroy_bitmap(jugador_sheet);
    al_destroy_event_queue(cola);
    al_destroy_display(ventana);

    return 0;
}